//
//  GameOrder.swift
//  Merge
//
//  주문 카드에 표시할 주문과 필요 아이템 규칙을 정의합니다.
//

struct OrderItemRequirement: Equatable {
    let itemKind: BoardItemKind
    let quantity: Int
}

import Foundation

struct GameOrder: Identifiable, Equatable {
    static let maximumActiveCount = 5

    // 같은 종류의 주문이 동시에 등장해도 서로 다른 카드로 취급하기 위한 실행 단위 ID입니다.
    let id: UUID
    // 밸런싱과 분석에서 어떤 주문 종류인지 구분하기 위한 고정 ID입니다.
    let templateID: String
    let title: String
    let requestedItem: OrderItemRequirement
    let recipeIngredients: [OrderItemRequirement]
    let coinReward: Int

    // 보드에 실제 납품 아이템이 충분히 있을 때만 완료할 수 있습니다.
    // 레시피 재료가 모두 있어도 완성 요리가 없다면 완료 상태가 되지 않습니다.
    func isReady(in itemCounts: [BoardItemKind: Int]) -> Bool {
        itemCounts[requestedItem.itemKind, default: 0] >= requestedItem.quantity
    }

    // 보드와 주문 카드에서 체크 표시가 필요한 모든 아이템 종류입니다.
    // 완성품과 조리 전 재료를 함께 포함해 플레이어가 주문에 쓸 수 있는 아이템을 알 수 있게 합니다.
    var relevantItemKinds: Set<BoardItemKind> {
        Set([requestedItem.itemKind] + recipeIngredients.map(\.itemKind))
    }

    // 바로 완료할 수 있는 주문을 왼쪽에 먼저 보여 주되 같은 상태끼리는 기존 순서를 유지합니다.
    // 아이템이 이미 소비된 납품 연출 중 주문도 왼쪽 위치를 유지해 애니메이션 목표가 움직이지 않게 합니다.
    static func prioritizedForDisplay(
        _ orders: [GameOrder],
        itemCounts: [BoardItemKind: Int],
        completingOrderIDs: Set<UUID>
    ) -> [GameOrder] {
        orders.enumerated()
            .sorted { first, second in
                let firstIsPrioritized = completingOrderIDs.contains(first.element.id)
                    || first.element.isReady(in: itemCounts)
                let secondIsPrioritized = completingOrderIDs.contains(second.element.id)
                    || second.element.isReady(in: itemCounts)

                if firstIsPrioritized == secondIsPrioritized {
                    return first.offset < second.offset
                }

                return firstIsPrioritized && !secondIsPrioritized
            }
            .map(\.element)
    }

    // 튜토리얼에서 처음 제시할 주문입니다.
    static var flourDelivery: GameOrder {
        GrainDeliveryOrder.flour.makeOrder()
    }

    static func randomGrainDelivery() -> GameOrder {
        GrainDeliveryOrder.allCases.randomElement()!.makeOrder()
    }
}

// 조리 시스템 전까지 사용할 곡물 머지 트리의 랜덤 주문 풀입니다.
// 주문 종류와 보상은 한곳에서 관리해 이후 해금 단계나 가중치를 붙이기 쉽게 둡니다.
enum GrainDeliveryOrder: CaseIterable {
    case flour
    case dough
    case noodle
    case riceCake

    func makeOrder(id: UUID = UUID()) -> GameOrder {
        switch self {
        case .flour:
            return GameOrder(
                id: id,
                templateID: "flour-delivery",
                title: "밀가루 배달",
                requestedItem: OrderItemRequirement(itemKind: .flour, quantity: 1),
                recipeIngredients: [],
                coinReward: 3
            )
        case .dough:
            return GameOrder(
                id: id,
                templateID: "dough-delivery",
                title: "반죽 배달",
                requestedItem: OrderItemRequirement(itemKind: .dough, quantity: 1),
                recipeIngredients: [],
                coinReward: 6
            )
        case .noodle:
            return GameOrder(
                id: id,
                templateID: "noodle-delivery",
                title: "면 배달",
                requestedItem: OrderItemRequirement(itemKind: .noodle, quantity: 1),
                recipeIngredients: [],
                coinReward: 14
            )
        case .riceCake:
            return GameOrder(
                id: id,
                templateID: "rice-cake-delivery",
                title: "떡 배달",
                requestedItem: OrderItemRequirement(itemKind: .riceCake, quantity: 1),
                recipeIngredients: [],
                coinReward: 30
            )
        }
    }
}
