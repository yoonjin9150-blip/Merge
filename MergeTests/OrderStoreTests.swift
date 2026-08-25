//
//  OrderStoreTests.swift
//  MergeTests
//
//  랜덤 주문 목록과 주문 완료 상태를 검증합니다.
//

import Foundation
import Testing
@testable import Merge

@MainActor
struct OrderStoreTests {
    @Test
    func 처음에는활성주문다섯개를채운다() {
        let store = OrderStore(makeRandomOrder: { .flourDelivery })

        #expect(store.activeOrders.count == 5)
        #expect(Set(store.activeOrders.map(\.id)).count == 5)
        #expect(store.activeOrders.first?.templateID == "flour-delivery")
    }

    @Test
    func 실제완료가확정되면주문을제거하고코인을지급한다() {
        let order = GrainDeliveryOrder.noodle.makeOrder()
        let store = OrderStore(
            initialOrders: [order],
            initialCoins: 2,
            makeRandomOrder: { .flourDelivery }
        )

        // 초기화 시 빈 주문 슬롯은 다섯 개까지 자동으로 채워집니다.
        #expect(store.beginCompletion(of: order))
        #expect(store.finishCompletion(of: order))
        #expect(!store.activeOrders.contains(where: { $0.id == order.id }))
        #expect(store.coins == 16)
        #expect(store.activeOrders.count == 4)
    }

    @Test
    func 같은주문은완료처리를동시에두번시작할수없다() {
        let order = GameOrder.flourDelivery
        let store = OrderStore(
            initialOrders: [order],
            makeRandomOrder: { .flourDelivery }
        )

        #expect(store.beginCompletion(of: order))
        #expect(!store.beginCompletion(of: order))

        store.cancelCompletion(of: order)
        #expect(store.beginCompletion(of: order))
    }

    @Test
    func 완료후빈자리는랜덤주문하나로보충한다() {
        let order = GameOrder.flourDelivery
        let store = OrderStore(
            initialOrders: [order],
            makeRandomOrder: { GrainDeliveryOrder.dough.makeOrder() }
        )

        #expect(store.beginCompletion(of: order))
        #expect(store.finishCompletion(of: order))
        #expect(store.activeOrders.count == 4)

        store.replenishOneOrder()

        #expect(store.activeOrders.count == 5)
        #expect(store.activeOrders.last?.templateID == "dough-delivery")
    }
}
