//
//  OrderStore.swift
//  Merge
//
//  활성 주문 목록과 주문 보상 코인을 관리합니다.
//

import Combine
import Foundation

@MainActor
final class OrderStore: ObservableObject {
    @Published private(set) var activeOrders: [GameOrder]
    @Published private(set) var completingOrderIDs: Set<UUID> = []
    @Published private(set) var coins: Int

    private let availableOrderTemplates: [GrainDeliveryOrder]

    init(
        initialOrders: [GameOrder]? = nil,
        initialCoins: Int = 0,
        availableOrderTemplates: [GrainDeliveryOrder] = GrainDeliveryOrder.allCases
    ) {
        precondition(initialCoins >= 0, "코인은 음수로 시작할 수 없습니다.")
        precondition(
            (initialOrders?.count ?? 0) <= GameOrder.maximumActiveCount,
            "활성 주문은 최대 \(GameOrder.maximumActiveCount)개입니다."
        )
        precondition(
            Set(initialOrders?.map(\.templateID) ?? []).count
                == (initialOrders?.count ?? 0),
            "같은 종류의 주문은 활성 목록에 중복될 수 없습니다."
        )

        // 첫 실행은 초반 진행이 막히지 않도록 밀가루 주문 한 개를 보장하고 나머지만 랜덤으로 채웁니다.
        // 테스트나 저장 복원처럼 목록을 직접 전달한 경우에는 전달받은 주문을 그대로 사용합니다.
        activeOrders = initialOrders ?? [.flourDelivery]
        coins = initialCoins
        self.availableOrderTemplates = availableOrderTemplates

        fillEmptySlots()
    }

    // 완료 버튼 연타로 같은 주문이 두 번 납품되지 않도록 먼저 처리 중 상태를 확보합니다.
    func beginCompletion(of order: GameOrder) -> Bool {
        guard activeOrders.contains(where: { $0.id == order.id }),
              !completingOrderIDs.contains(order.id) else {
            return false
        }

        completingOrderIDs.insert(order.id)
        return true
    }

    // SpriteKit이 실제 아이템 소비에 성공한 뒤에만 주문 제거와 코인 지급을 확정합니다.
    @discardableResult
    func finishCompletion(of order: GameOrder) -> Bool {
        guard completingOrderIDs.remove(order.id) != nil,
              let index = activeOrders.firstIndex(where: { $0.id == order.id }) else {
            return false
        }

        let completedOrder = activeOrders.remove(at: index)
        coins += completedOrder.coinReward
        return true
    }

    func cancelCompletion(of order: GameOrder) {
        completingOrderIDs.remove(order.id)
    }

    // 완료 카드가 사라진 뒤 호출하여 현재 목록에 없는 주문 종류 하나로 빈자리를 채웁니다.
    func replenishOneOrder() {
        guard activeOrders.count < GameOrder.maximumActiveCount,
              let replacement = makeRandomAvailableOrder() else {
            return
        }

        activeOrders.append(replacement)
    }

    private func fillEmptySlots() {
        while activeOrders.count < GameOrder.maximumActiveCount,
              let order = makeRandomAvailableOrder() {
            activeOrders.append(order)
        }
    }

    private func makeRandomAvailableOrder() -> GameOrder? {
        let activeTemplateIDs = Set(activeOrders.map(\.templateID))
        let candidates = availableOrderTemplates.filter {
            !activeTemplateIDs.contains($0.templateID)
        }

        return candidates.randomElement()?.makeOrder()
    }
}
