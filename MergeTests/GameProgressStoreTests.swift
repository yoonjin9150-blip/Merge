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
    func 챕터별로다음진행조건과해금보상을안내한다() {
        #expect(GameChapter.relightStove.title == "화구 되살리기")
        #expect(
            GameChapter.relightStove.nextChapterRequirement
                == "수제비 첫 주문을 완료하세요."
        )
        #expect(
            GameChapter.relightStove.nextChapterReward
                == "CH.2 · 장독대와 후라이팬 해금"
        )
        #expect(
            GameChapter.restoreJangFlavor.nextChapterRequirement
                == "떡볶이 첫 주문을 완료하세요."
        )
        #expect(
            GameChapter.restoreJangFlavor.nextChapterReward
                == "CH.3 · 베이킹 찬장 해금"
        )
        #expect(GameChapter.openBakery.nextChapterRequirement == nil)
        #expect(GameChapter.openBakery.nextChapterReward == nil)
        #expect(
            GameChapter.relightStove.storyOrderTemplateID
                == GameOrderTemplate.cooking(.sujebi).templateID
        )
        #expect(
            GameChapter.restoreJangFlavor.storyOrderTemplateID
                == GameOrderTemplate.cooking(.tteokbokki).templateID
        )
        #expect(GameChapter.openBakery.storyOrderTemplateID == nil)
        #expect(!GameChapter.restoreJangFlavor.storyDescription.isEmpty)
    }

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
        let sujebiOrder = GameOrderTemplate.cooking(.sujebi).makeOrder()

        #expect(store.recordCompletedOrder(sujebiOrder))
        #expect(store.currentChapter == .restoreJangFlavor)
        #expect(!store.recordCompletedOrder(sujebiOrder))
    }

    @Test
    func 해금한챕터는앱을다시실행해도복원된다() {
        let defaults = makeDefaults()
        let firstStore = GameProgressStore(defaults: defaults)

        #expect(
            firstStore.recordCompletedOrder(
                GameOrderTemplate.cooking(.sujebi).makeOrder()
            )
        )

        let restoredStore = GameProgressStore(defaults: defaults)
        #expect(restoredStore.currentChapter == .restoreJangFlavor)
    }

    @Test
    func 장맛복구중첫떡볶이납품은베이킹챕터를해금한다() {
        let store = GameProgressStore(
            initialChapter: .restoreJangFlavor,
            defaults: makeDefaults()
        )
        let tteokbokkiOrder = GameOrderTemplate.cooking(.tteokbokki).makeOrder()

        #expect(store.recordCompletedOrder(tteokbokkiOrder))
        #expect(store.currentChapter == .openBakery)
        #expect(!store.recordCompletedOrder(tteokbokkiOrder))
    }

    @Test
    func 장맛복구중다른주문은베이킹챕터를해금하지않는다() {
        let store = GameProgressStore(
            initialChapter: .restoreJangFlavor,
            defaults: makeDefaults()
        )

        #expect(
            !store.recordCompletedOrder(
                GameOrderTemplate.cooking(.sujebi).makeOrder()
            )
        )
        #expect(store.currentChapter == .restoreJangFlavor)
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName = "GameProgressStoreTests.\(UUID().uuidString)"
        return UserDefaults(suiteName: suiteName)!
    }
}
