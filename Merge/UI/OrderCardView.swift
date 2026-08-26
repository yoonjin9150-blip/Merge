//
//  OrderCardView.swift
//  Merge
//
//  활성 주문의 필요 아이템, 준비 상태, 코인 보상을 표시합니다.
//

import SwiftUI

struct OrderCardView: View {
    let order: GameOrder
    let itemCounts: [BoardItemKind: Int]
    let isCompleting: Bool
    let onComplete: (CGPoint) -> Void

    init(order: GameOrder) {
        self.order = order
        itemCounts = [:]
        isCompleting = false
        onComplete = { _ in }
    }

    init(
        order: GameOrder,
        itemCounts: [BoardItemKind: Int],
        isCompleting: Bool = false,
        onComplete: @escaping (CGPoint) -> Void
    ) {
        self.order = order
        self.itemCounts = itemCounts
        self.isCompleting = isCompleting
        self.onComplete = onComplete
    }

    private let outlineColor = Color(
        red: 0.08,
        green: 0.07,
        blue: 0.20
    )

    private var isReady: Bool {
        order.isReady(in: itemCounts)
    }

    private var cardHeight: CGFloat {
        if order.requiredToolKind != nil {
            return 166
        }

        return order.recipeIngredients.isEmpty ? 110 : 142
    }

    var body: some View {
        GeometryReader { geometry in
            cardContent(
                deliveryTarget: CGPoint(
                    x: geometry.frame(in: .named("gameRoot")).midX,
                    y: geometry.frame(in: .named("gameRoot")).midY
                )
            )
        }
        .frame(width: 120, height: cardHeight)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 1, green: 0.97, blue: 0.85))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isReady
                                ? Color(red: 0.20, green: 0.72, blue: 0.36)
                                : outlineColor,
                            lineWidth: 3
                        )
                }
                .shadow(
                    color: outlineColor.opacity(0.28),
                    radius: 0,
                    x: 3,
                    y: 4
                )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(order.title)
        .accessibilityValue(
            isReady
                ? "납품 준비 완료, 보상 \(order.coinReward)코인"
                : "납품 아이템 부족, 보상 \(order.coinReward)코인"
        )
    }

    private func cardContent(deliveryTarget: CGPoint) -> some View {
        VStack(spacing: 5) {
            HStack(alignment: .top, spacing: 5) {
                requestedItem

                Spacer(minLength: 0)

                reward
            }

            if !order.recipeIngredients.isEmpty {
                recipeIngredients
            }

            if let requiredToolKind = order.requiredToolKind {
                requiredTool(requiredToolKind)
            }

            Button(isCompleting ? "납품 중" : "완료") {
                onComplete(deliveryTarget)
            }
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(
                    isReady && !isCompleting
                        ? Color.white
                        : outlineColor.opacity(0.45)
                )
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            isReady && !isCompleting
                                ? Color(red: 0.20, green: 0.72, blue: 0.36)
                                : outlineColor.opacity(0.10)
                        )
                }
                .disabled(!isReady || isCompleting)
                .accessibilityLabel("\(order.title) 완료")
                .accessibilityHint(
                    isReady
                        ? "두 번 탭하면 주문을 납품합니다."
                        : "납품할 아이템이 부족합니다."
                )
        }
        .padding(8)
    }

    private var requestedItem: some View {
        VStack(spacing: 1) {
            OrderItemImage(
                requirement: order.requestedItem,
                availableQuantity: itemCounts[
                    order.requestedItem.itemKind,
                    default: 0
                ],
                sideLength: 48
            )

            Text(order.title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    private var recipeIngredients: some View {
        HStack(spacing: 2) {
            ForEach(
                Array(order.recipeIngredients.enumerated()),
                id: \.offset
            ) { index, ingredient in
                if index > 0 {
                    Text("+")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(outlineColor)
                }

                OrderItemImage(
                    requirement: ingredient,
                    availableQuantity: itemCounts[ingredient.itemKind, default: 0],
                    sideLength: 28
                )
            }
        }
    }

    private func requiredTool(_ kind: BoardItemKind) -> some View {
        HStack(spacing: 4) {
            Text("사용 도구")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor.opacity(0.72))

            Image(kind.textureName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 22, height: 22)

            if itemCounts[kind, default: 0] > 0 {
                PixelPreparedCheck()
                    .scaleEffect(0.78)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityLabel("필요한 사용 도구")
        .accessibilityValue(itemCounts[kind, default: 0] > 0 ? "준비됨" : "없음")
    }

    private var reward: some View {
        HStack(spacing: 2) {
            PixelCoinIcon()

            Text("\(order.coinReward)")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)
                .monospacedDigit()
        }
    }
}

private struct OrderItemImage: View {
    let requirement: OrderItemRequirement
    let availableQuantity: Int
    let sideLength: CGFloat

    private var isPrepared: Bool {
        availableQuantity >= requirement.quantity
    }

    var body: some View {
        ZStack {
            Image(requirement.itemKind.textureName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: sideLength, height: sideLength)

            Text("×\(requirement.quantity)")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.08, green: 0.07, blue: 0.20))
                .padding(.horizontal, 2)
                .background(Color(red: 1, green: 0.97, blue: 0.85).opacity(0.9))
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .bottomLeading
                )

            if isPrepared {
                PixelPreparedCheck()
                    .offset(x: 3, y: 3)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .bottomTrailing
                    )
            }
        }
        .frame(width: sideLength, height: sideLength)
        .accessibilityHidden(true)
    }
}

private struct PixelPreparedCheck: View {
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(Color.white)
            .frame(width: 16, height: 16)
            .background(Color(red: 0.20, green: 0.72, blue: 0.36))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.white, lineWidth: 1.5)
            }
    }
}

#Preview {
    HStack {
        OrderCardView(
            order: .flourDelivery,
            itemCounts: [:],
            onComplete: { _ in }
        )

        OrderCardView(
            order: .flourDelivery,
            itemCounts: [.flour: 1],
            onComplete: { _ in }
        )
    }
    .padding()
    .background(Color(red: 0.68, green: 0.86, blue: 0.98))
}
