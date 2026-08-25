//
//  GameOrder.swift
//  Merge
//
//  주문 카드에 표시할 주문의 기본 정보를 정의합니다.
//

struct GameOrder: Identifiable {
    let id: String
    let title: String
    let requiredItemKind: BoardItemKind
    let requiredQuantity: Int
    let coinReward: Int

    // 튜토리얼에서 처음 제시할 주문입니다.
    static let flourDelivery = GameOrder(
        id: "flour-delivery",
        title: "밀가루 배달",
        requiredItemKind: .flour,
        requiredQuantity: 1,
        coinReward: 3
    )
}
