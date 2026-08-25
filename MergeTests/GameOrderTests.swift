//
//  GameOrderTests.swift
//  MergeTests
//
//  주문 카드 데이터와 준비 상태 규칙을 검증합니다.
//

import Testing
@testable import Merge

@MainActor
struct GameOrderTests {
    @Test
    func 첫주문은밀가루한개를요구하고3코인을보상한다() {
        let order = GameOrder.flourDelivery

        #expect(order.id == "flour-delivery")
        #expect(order.title == "밀가루 배달")
        #expect(order.requestedItem.itemKind == .flour)
        #expect(order.requestedItem.quantity == 1)
        #expect(order.recipeIngredients.isEmpty)
        #expect(order.coinReward == 3)
    }

    @Test
    func 주문아이템이충분할때만완료할수있다() {
        let order = GameOrder.flourDelivery

        #expect(!order.isReady(in: [:]))
        #expect(order.isReady(in: [.flour: 1]))
        #expect(order.isReady(in: [.flour: 2]))
    }

    @Test
    func 주문관련아이템에는완성품과레시피재료가포함된다() {
        let cookingOrder = GameOrder(
            id: "prototype-cooking-order",
            title: "시험 요리",
            requestedItem: OrderItemRequirement(
                itemKind: .riceCake,
                quantity: 1
            ),
            recipeIngredients: [
                OrderItemRequirement(itemKind: .flour, quantity: 1),
                OrderItemRequirement(itemKind: .dough, quantity: 1)
            ],
            coinReward: 10
        )

        #expect(
            cookingOrder.relevantItemKinds
                == Set([.riceCake, .flour, .dough])
        )
        #expect(
            !cookingOrder.isReady(
                in: [.flour: 1, .dough: 1]
            )
        )
    }

    @Test
    func 활성주문은최대다섯개다() {
        #expect(GameOrder.maximumActiveCount == 5)
    }
}
