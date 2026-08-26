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
    func 냄비상품은오코인이며냄비보드아이템과연결된다() {
        #expect(ShopProduct.cookingPot.price == 5)
        #expect(ShopProduct.cookingPot.boardItemKind == .cookingPot)
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
}
