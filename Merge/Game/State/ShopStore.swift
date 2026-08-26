//
//  ShopStore.swift
//  Merge
//
//  영구 구매한 상점 상품을 기기에 저장하고 복원합니다.
//

import Combine
import Foundation

@MainActor
final class ShopStore: ObservableObject {
    @Published private(set) var purchasedProducts: Set<ShopProduct>

    private enum StorageKey {
        static let purchasedProductIDs = "shop.purchasedProductIDs"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedIDs = defaults.stringArray(
            forKey: StorageKey.purchasedProductIDs
        ) ?? []
        purchasedProducts = Set(storedIDs.compactMap(ShopProduct.init(rawValue:)))
    }

    func isPurchased(_ product: ShopProduct) -> Bool {
        purchasedProducts.contains(product)
    }

    // 실제 코인 결제와 보드 배치가 모두 성공한 뒤에만 호출합니다.
    @discardableResult
    func markPurchased(_ product: ShopProduct) -> Bool {
        let didInsert = purchasedProducts.insert(product).inserted

        if didInsert {
            save()
        }

        return didInsert
    }

    private func save() {
        defaults.set(
            purchasedProducts.map(\.rawValue).sorted(),
            forKey: StorageKey.purchasedProductIDs
        )
    }
}
