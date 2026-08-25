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

struct GameOrder: Identifiable {
    let id: String
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

    // 튜토리얼에서 처음 제시할 주문입니다.
    static let flourDelivery = GameOrder(
        id: "flour-delivery",
        title: "밀가루 배달",
        requestedItem: OrderItemRequirement(
            itemKind: .flour,
            quantity: 1
        ),
        recipeIngredients: [],
        coinReward: 3
    )
}
