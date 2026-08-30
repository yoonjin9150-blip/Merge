//
//  GameProgressStoreTests.swift
//  MergeTests
//
//  주문 완료에 따른 챕터 전환과 저장·복원을 검증합니다.
//

import Foundation
import Testing
@testable import Merge

@MainActor
struct GameProgressStoreTests {
    @Test
    func 새게임은화구복구챕터에서시작한다() {
        let defaults = makeDefaults()

        let store = GameProgressStore(defaults: defaults)

        #expect(store.currentChapter == .relightStove)
    }

    @Test
    func 곡물납품은첫챕터를완료하지않는다() {
        let store = GameProgressStore(defaults: makeDefaults())

        #expect(!store.recordCompletedOrder(.flourDelivery))
        #expect(store.currentChapter == .relightStove)
    }

    @Test
    func 첫수제비납품은장맛복구챕터를해금한다() {
        let store = GameProgressStore(defaults: makeDefaults())
        let sujebiOrder = GameOrderTemplate.sujebi.makeOrder()

        #expect(store.recordCompletedOrder(sujebiOrder))
        #expect(store.currentChapter == .restoreJangFlavor)
        #expect(!store.recordCompletedOrder(sujebiOrder))
    }

    @Test
    func 해금한챕터는앱을다시실행해도복원된다() {
        let defaults = makeDefaults()
        let firstStore = GameProgressStore(defaults: defaults)

        #expect(firstStore.recordCompletedOrder(GameOrderTemplate.sujebi.makeOrder()))

        let restoredStore = GameProgressStore(defaults: defaults)
        #expect(restoredStore.currentChapter == .restoreJangFlavor)
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "GameProgressStoreTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}
