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
    func 현재고유주문네종을중복없이채운다() {
        let store = OrderStore()

        #expect(store.activeOrders.count == 4)
        #expect(Set(store.activeOrders.map(\.id)).count == 4)
        #expect(Set(store.activeOrders.map(\.templateID)).count == 4)
        #expect(store.activeOrders.first?.templateID == "flour-delivery")
    }

    @Test
    func 냄비구매후수제비주문을해금하면다섯번째고유주문이생긴다() {
        let store = OrderStore()

        #expect(!store.activeOrders.contains(where: { $0.templateID == "sujebi-order" }))
        #expect(store.unlock(.cooking(.sujebi)))
        #expect(store.activeOrders.count == 5)
        #expect(store.activeOrders.contains(where: { $0.templateID == "sujebi-order" }))
        #expect(Set(store.activeOrders.map(\.templateID)).count == 5)
        #expect(!store.unlock(.cooking(.sujebi)))
        #expect(store.activeOrders.count == 5)
    }

    @Test
    func 실제완료가확정되면주문을제거하고코인을지급한다() {
        let defaults = makeDefaults()
        let order = GrainDeliveryOrder.noodle.makeOrder()
        let store = OrderStore(
            initialOrders: [order],
            initialCoins: 2,
            defaults: defaults
        )

        // 초기화 시 현재 고유 주문 풀의 네 종류까지 자동으로 채워집니다.
        #expect(store.beginCompletion(of: order))
        #expect(store.finishCompletion(of: order))
        #expect(!store.activeOrders.contains(where: { $0.id == order.id }))
        #expect(store.coins == 16)
        #expect(store.activeOrders.count == 3)
    }

    @Test
    func 코인은앱을다시실행해도저장된값으로복원된다() {
        let defaults = makeDefaults()
        let order = GrainDeliveryOrder.flour.makeOrder()
        let firstStore = OrderStore(
            initialOrders: [order],
            initialCoins: 4,
            defaults: defaults
        )

        #expect(firstStore.beginCompletion(of: order))
        #expect(firstStore.finishCompletion(of: order))
        #expect(firstStore.coins == 7)

        let restoredStore = OrderStore(
            initialOrders: [],
            defaults: defaults
        )
        #expect(restoredStore.coins == 7)
    }

    @Test
    func 구매외부작업이실패하면코인을차감하지않는다() {
        let store = OrderStore(
            initialOrders: [],
            initialCoins: 5,
            defaults: makeDefaults()
        )

        let didPurchase = store.purchase(cost: 5) { false }

        #expect(!didPurchase)
        #expect(store.coins == 5)
    }

    @Test
    func 구매외부작업이성공하면가격만큼코인을차감한다() {
        let defaults = makeDefaults()
        let store = OrderStore(
            initialOrders: [],
            initialCoins: 8,
            defaults: defaults
        )

        let didPurchase = store.purchase(cost: 5) { true }

        #expect(didPurchase)
        #expect(store.coins == 3)
        #expect(
            OrderStore(initialOrders: [], defaults: defaults).coins == 3
        )
    }

    @Test
    func 같은주문은완료처리를동시에두번시작할수없다() {
        let order = GameOrder.flourDelivery
        let store = OrderStore(initialOrders: [order])

        #expect(store.beginCompletion(of: order))
        #expect(!store.beginCompletion(of: order))

        store.cancelCompletion(of: order)
        #expect(store.beginCompletion(of: order))
    }

    @Test
    func 완료후빈자리는현재목록에없는주문으로보충한다() {
        let order = GameOrder.flourDelivery
        let store = OrderStore(initialOrders: [order])

        #expect(store.beginCompletion(of: order))
        #expect(store.finishCompletion(of: order))
        #expect(store.activeOrders.count == 3)

        store.replenishOneOrder()

        #expect(store.activeOrders.count == 4)
        #expect(store.activeOrders.last?.templateID == "flour-delivery")
        #expect(Set(store.activeOrders.map(\.templateID)).count == 4)
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "OrderStoreTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}
