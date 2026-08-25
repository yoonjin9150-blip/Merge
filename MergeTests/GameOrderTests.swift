//
//  GameOrderTests.swift
//  MergeTests
//
//  첫 주문 카드에 표시할 데이터를 검증합니다.
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
        #expect(order.requiredItemKind == .flour)
        #expect(order.requiredQuantity == 1)
        #expect(order.coinReward == 3)
    }
}
