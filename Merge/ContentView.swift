//
//  ContentView.swift
//  Merge
//
//  Created by 이윤진 on 8/16/26.
//

import Combine
import SpriteKit
import SwiftUI

private enum OrderCompletionTiming {
    // 보드 아이템이 주문 카드까지 날아가는 시간입니다.
    static let deliveryDuration: TimeInterval = 0.38
    static let deliveryDurationNanoseconds: UInt64 = 380_000_000

    // 완료 카드가 사라진 뒤 새 주문이 나타나기 전까지 기다리는 시간입니다.
    // 현재 게임 규칙은 30초이며, 그동안 빈자리에 별도 대기 표시는 보여 주지 않습니다.
    static let replenishmentDelayNanoseconds: UInt64 = 30_000_000_000
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var energyStore = EnergyStore()
    @StateObject private var orderStore = OrderStore()
    @StateObject private var shopStore = ShopStore()
    @State private var isShopPresented = false

    private var activeOrders: [GameOrder] {
        orderStore.activeOrders
    }

    private var topHUDHeight: CGFloat {
        activeOrders.contains(where: { !$0.recipeIngredients.isEmpty })
            ? 234
            : 202
    }

    // SpriteKit 보드가 알려 주는 아이템 종류별 개수입니다.
    // 주문 카드의 체크와 완료 버튼 상태를 계산하는 데 사용합니다.
    @State private var boardItemCounts: [BoardItemKind: Int] = [:]
    @State private var deliveryEffects: [OrderDeliveryEffect] = []

    // SpriteKit 게임판입니다. 화면 크기에 맞춰 장면의 크기도 바뀝니다.
    @State private var boardScene: MergeBoardScene = {
        let scene = MergeBoardScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    // 실제 회복량은 저장된 시각 차이로 계산하고, 이 타이머는 화면 표시만 매초 갱신합니다.
    private let energyTicker = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        ZStack {
            // 상단·SpriteKit·하단 영역 뒤로 하나의 픽셀 하늘 배경이 이어집니다.
            PixelSkyBackground()

            VStack(spacing: 0) {
                // 에너지·코인 상태와 최대 다섯 개의 주문 목록을 표시하는 상단 HUD입니다.
                VStack(spacing: 0) {
                    HStack {
                        EnergyStatusView(
                            currentEnergy: energyStore.currentEnergy,
                            maximumEnergy: energyStore.maximumEnergy,
                            secondsUntilNextRecovery: energyStore.secondsUntilNextRecovery
                        )

                        CoinStatusView(coins: orderStore.coins)

                        Spacer()

                        Button {
                            isShopPresented = true
                        } label: {
                            Text("상점")
                                .font(.system(size: 15, weight: .black, design: .rounded))
                                .foregroundStyle(Color(red: 0.08, green: 0.07, blue: 0.20))
                                .padding(.horizontal, 12)
                                .frame(height: 44)
                                .background {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(red: 1, green: 0.80, blue: 0.36))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    Color(red: 0.08, green: 0.07, blue: 0.20),
                                                    lineWidth: 3
                                                )
                                        }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 14)
                    .padding(.horizontal, 24)

                    OrderStripView(
                        orders: activeOrders,
                        itemCounts: boardItemCounts,
                        completingOrderIDs: orderStore.completingOrderIDs,
                        onComplete: { order, target in
                            complete(order, toward: target)
                        }
                    )
                    .padding(.top, 8)

                    Spacer(minLength: 0)
                }
                    .frame(height: topHUDHeight)

                // SpriteKit 장면을 투명하게 표시해 뒤의 픽셀 하늘이 그대로 보이게 합니다.
                SpriteView(
                    scene: boardScene,
                    options: [.allowsTransparency]
                )

                // 나중에 안내 문구가 들어갈 하단 영역입니다.
                Color.clear
                    .frame(height: 76)
            }

            ForEach(deliveryEffects) { effect in
                OrderDeliveryEffectView(effect: effect)
            }
        }
        .coordinateSpace(name: "gameRoot")
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            // SpriteKit은 빈 칸을 확인한 뒤 이 클로저를 호출해 성공할 스폰의 에너지만 차감합니다.
            boardScene.consumeEnergyForSpawn = { [weak energyStore] in
                energyStore?.consumeForSuccessfulSpawn() ?? false
            }

            // 주문에 필요한 아이템 종류를 SpriteKit에 알려 보드 아이템의 체크를 표시합니다.
            boardScene.activeOrderItemKinds = Set(
                activeOrders.flatMap(\.relevantItemKinds)
            )
            boardScene.onBoardItemCountsChanged = { counts in
                boardItemCounts = counts
            }
            synchronizePurchasedBoardItems(shopStore.purchasedProducts)
            energyStore.refresh()
        }
        .onReceive(orderStore.$activeOrders) { orders in
            // 주문 완료와 새 주문 보충 때 보드의 준비 체크 대상도 즉시 다시 계산합니다.
            boardScene.activeOrderItemKinds = Set(
                orders.flatMap(\.relevantItemKinds)
            )
        }
        .onReceive(energyTicker) { date in
            energyStore.refresh(at: date)
        }
        .onReceive(shopStore.$purchasedProducts) { purchasedProducts in
            // @Published가 전달한 최신 값을 직접 사용해 저장 프로퍼티 갱신 시점에 의존하지 않습니다.
            synchronizePurchasedBoardItems(purchasedProducts)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // 백그라운드나 앱 종료 중 흐른 시간을 화면에 복귀할 때 즉시 반영합니다.
                energyStore.refresh()
            }
        }
        .sheet(isPresented: $isShopPresented) {
            ShopView(
                coins: orderStore.coins,
                isCookingPotPurchased: shopStore.isPurchased(.cookingPot),
                canPlaceCookingPot: boardScene.canPlacePermanentItem(.cookingPot),
                onPurchaseCookingPot: {
                    purchase(.cookingPot)
                }
            )
            .presentationDetents([.large])
        }
    }

    private func complete(_ order: GameOrder, toward target: CGPoint) {
        // 같은 완료 버튼을 연타해 중복 소비·중복 보상이 발생하지 않도록 먼저 잠급니다.
        guard orderStore.beginCompletion(of: order) else {
            return
        }

        // 버튼의 준비 표시와 별개로 SpriteKit의 현재 보드에서 실제 아이템을 다시 찾습니다.
        guard let deliveredItems = boardScene.consumeItemsForOrder(order.requestedItem) else {
            orderStore.cancelCompletion(of: order)
            return
        }

        let newEffects = deliveredItems.map { item in
            OrderDeliveryEffect(
                kind: item.kind,
                start: rootPosition(for: item.scenePosition),
                target: target
            )
        }
        deliveryEffects.append(contentsOf: newEffects)

        let effectIDs = Set(newEffects.map(\.id))

        Task { @MainActor in
            // 보드에서 주문 카드까지 날아가는 연출이 끝난 뒤 보상과 카드 제거를 확정합니다.
            try? await Task.sleep(
                nanoseconds: OrderCompletionTiming.deliveryDurationNanoseconds
            )
            deliveryEffects.removeAll { effectIDs.contains($0.id) }

            guard orderStore.finishCompletion(of: order) else {
                return
            }

            // 완료 카드가 사라진 것을 먼저 보여 준 뒤 새 랜덤 주문으로 빈자리를 채웁니다.
            try? await Task.sleep(
                nanoseconds: OrderCompletionTiming.replenishmentDelayNanoseconds
            )
            orderStore.replenishOneOrder()
        }
    }

    private func purchase(_ product: ShopProduct) -> Bool {
        guard !shopStore.isPurchased(product) else {
            return false
        }

        return orderStore.purchase(cost: product.price) {
            let kind = product.boardItemKind

            guard boardScene.placePermanentItemIfPossible(kind) else {
                return false
            }

            guard shopStore.markPurchased(product) else {
                // 저장 상태가 예상과 달라 구매 확정에 실패하면 화면 배치도 함께 되돌립니다.
                boardScene.removePermanentItem(kind)
                return false
            }

            return true
        }
    }

    private func synchronizePurchasedBoardItems(
        _ purchasedProducts: Set<ShopProduct>
    ) {
        // 상품 선언 순서를 사용해 이후 조리도구가 늘어나도 복원 위치가 매번 같도록 합니다.
        boardScene.purchasedPermanentItemKinds = ShopProduct.allCases
            .filter(purchasedProducts.contains)
            .map(\.boardItemKind)
    }

    private func rootPosition(for scenePosition: CGPoint) -> CGPoint {
        // SpriteKit은 왼쪽 아래가 원점이고 SwiftUI는 왼쪽 위가 원점이므로 y축을 뒤집습니다.
        // SpriteView는 상단 HUD 바로 아래에 있으므로 그 높이도 더해 게임 전체 좌표로 변환합니다.
        CGPoint(
            x: scenePosition.x,
            y: topHUDHeight + boardScene.size.height - scenePosition.y
        )
    }
}

private struct OrderDeliveryEffect: Identifiable {
    let id = UUID()
    let kind: BoardItemKind
    let start: CGPoint
    let target: CGPoint
}

private struct OrderDeliveryEffectView: View {
    let effect: OrderDeliveryEffect

    @State private var reachedTarget = false

    var body: some View {
        Image(effect.kind.textureName)
            .resizable()
            .interpolation(.none)
            .scaledToFit()
            .frame(width: 44, height: 44)
            .scaleEffect(reachedTarget ? 0.35 : 1)
            .opacity(reachedTarget ? 0.2 : 1)
            .position(reachedTarget ? effect.target : effect.start)
            .allowsHitTesting(false)
            .onAppear {
                withAnimation(.easeIn(duration: OrderCompletionTiming.deliveryDuration)) {
                    reachedTarget = true
                }
            }
    }
}

private struct PixelSkyBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.68, green: 0.86, blue: 0.98)

                PixelSparkle(pixelSize: 4)
                    .position(x: geometry.size.width * 0.14, y: geometry.size.height * 0.12)
                PixelSparkle(pixelSize: 3)
                    .position(x: geometry.size.width * 0.80, y: geometry.size.height * 0.18)
                PixelSparkle(pixelSize: 3)
                    .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.23)
                PixelSparkle(pixelSize: 2)
                    .position(x: geometry.size.width * 0.91, y: geometry.size.height * 0.27)
                PixelSparkle(pixelSize: 4)
                    .position(x: geometry.size.width * 0.18, y: geometry.size.height * 0.82)
                PixelSparkle(pixelSize: 3)
                    .position(x: geometry.size.width * 0.84, y: geometry.size.height * 0.74)
                PixelSparkle(pixelSize: 2)
                    .position(x: geometry.size.width * 0.50, y: geometry.size.height * 0.93)

                PixelSquare(size: 6)
                    .position(x: geometry.size.width * 0.32, y: geometry.size.height * 0.09)
                PixelSquare(size: 5)
                    .position(x: geometry.size.width * 0.88, y: geometry.size.height * 0.31)
                PixelSquare(size: 4)
                    .position(x: geometry.size.width * 0.67, y: geometry.size.height * 0.14)
                PixelSquare(size: 5)
                    .position(x: geometry.size.width * 0.09, y: geometry.size.height * 0.27)
                PixelSquare(size: 6)
                    .position(x: geometry.size.width * 0.73, y: geometry.size.height * 0.88)
                PixelSquare(size: 4)
                    .position(x: geometry.size.width * 0.10, y: geometry.size.height * 0.66)
                PixelSquare(size: 4)
                    .position(x: geometry.size.width * 0.91, y: geometry.size.height * 0.90)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct PixelSparkle: View {
    let pixelSize: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: pixelSize * 3, height: pixelSize)
            Rectangle()
                .frame(width: pixelSize, height: pixelSize * 3)
        }
        .foregroundStyle(Color(red: 1, green: 0.98, blue: 0.89))
    }
}

private struct PixelSquare: View {
    let size: CGFloat

    var body: some View {
        Rectangle()
            .fill(Color(red: 1, green: 0.43, blue: 0.35))
            .frame(width: size, height: size)
    }
}

#Preview {
    ContentView()
}
