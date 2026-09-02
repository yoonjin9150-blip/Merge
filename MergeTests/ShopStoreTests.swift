//
//  ShopStoreTests.swift
//  MergeTests
//
//  상점의 영구 구매 상태 저장과 상품 규칙을 검증합니다.
//

import Foundation
import Testing
@testable import Merge

@MainActor
struct ShopStoreTests {
    @Test
    func 상품은각챕터에맞춰순서대로열린다() {
        #expect(ShopProduct.cookingPot.isUnlocked(in: .relightStove))
        #expect(!ShopProduct.fryingPan.isUnlocked(in: .relightStove))
        #expect(!ShopProduct.jangdokdae.isUnlocked(in: .relightStove))
        #expect(ShopProduct.fryingPan.isUnlocked(in: .restoreJangFlavor))
        #expect(ShopProduct.jangdokdae.isUnlocked(in: .restoreJangFlavor))
        #expect(!ShopProduct.bakingCabinet.isUnlocked(in: .restoreJangFlavor))
        #expect(ShopProduct.bakingCabinet.isUnlocked(in: .openBakery))
        #expect(ShopProduct.fryingPan.requiredChapter.shortBadge == "CH.2")
        #expect(ShopProduct.jangdokdae.requiredChapter.shortBadge == "CH.2")
        #expect(ShopProduct.bakingCabinet.requiredChapter.shortBadge == "CH.3")
    }

    @Test
    func 상점설명은조작순서보다상품의역할을알려준다() {
        #expect(
            ShopProduct.cookingPot.description
                == "재료를 넣어 다양한 음식을 만드는\n영구 조리도구예요."
        )
        #expect(
            ShopProduct.jangdokdae.description
                == "에너지를 사용해 고추를 만들어 내는\n영구 생성기예요."
        )
        #expect(
            ShopProduct.bakingCabinet.description
                == "에너지를 사용해 베이킹 재료를 만드는\n영구 생성기예요."
        )
        #expect(ShopProduct.jangdokdae.lockedButtonTitle == "수제비 주문 완료 시 해금")
        #expect(ShopProduct.bakingCabinet.lockedButtonTitle == "떡볶이 주문 완료 시 해금")
    }

    @Test
    func 냄비상품은오코인이며냄비보드아이템과연결된다() {
        #expect(ShopProduct.cookingPot.price == 5)
        #expect(ShopProduct.cookingPot.boardItemKind == .cookingPot)
    }

    @Test
    func 장독대상품은임시삼십코인이며장독대생성기와연결된다() {
        #expect(ShopProduct.jangdokdae.price == 30)
        #expect(ShopProduct.jangdokdae.boardItemKind == .jangdokdae)
    }

    @Test
    func 후라이팬상품은육십코인이며후라이팬보드아이템과연결된다() {
        #expect(ShopProduct.fryingPan.price == 60)
        #expect(ShopProduct.fryingPan.boardItemKind == .fryingPan)
    }

    @Test
    func 베이킹찬장상품은임시백코인이며생성기와연결된다() {
        #expect(ShopProduct.bakingCabinet.price == 100)
        #expect(ShopProduct.bakingCabinet.boardItemKind == .bakingCabinet)
    }

    @Test
    func 구매한냄비는앱을다시실행해도복원된다() {
        let suiteName = "ShopStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let firstStore = ShopStore(defaults: defaults)
        #expect(!firstStore.isPurchased(.cookingPot))
        #expect(firstStore.markPurchased(.cookingPot))

        let restoredStore = ShopStore(defaults: defaults)
        #expect(restoredStore.isPurchased(.cookingPot))
        #expect(!restoredStore.markPurchased(.cookingPot))
    }

    @Test
    func 구매한장독대는앱을다시실행해도복원된다() {
        let suiteName = "ShopStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let firstStore = ShopStore(defaults: defaults)
        #expect(firstStore.markPurchased(.jangdokdae))

        let restoredStore = ShopStore(defaults: defaults)
        #expect(restoredStore.isPurchased(.jangdokdae))
        #expect(!restoredStore.markPurchased(.jangdokdae))
    }

    @Test
    func 구매한후라이팬은앱을다시실행해도복원된다() {
        let suiteName = "ShopStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let firstStore = ShopStore(defaults: defaults)
        #expect(firstStore.markPurchased(.fryingPan))

        let restoredStore = ShopStore(defaults: defaults)
        #expect(restoredStore.isPurchased(.fryingPan))
        #expect(!restoredStore.markPurchased(.fryingPan))
    }

    @Test
    func 구매한베이킹찬장은앱을다시실행해도복원된다() {
        let suiteName = "ShopStoreTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let firstStore = ShopStore(defaults: defaults)
        #expect(firstStore.markPurchased(.bakingCabinet))

        let restoredStore = ShopStore(defaults: defaults)
        #expect(restoredStore.isPurchased(.bakingCabinet))
        #expect(!restoredStore.markPurchased(.bakingCabinet))
    }
}
