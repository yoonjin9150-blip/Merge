//
//  ShopProduct.swift
//  Merge
//
//  상점에서 구매할 수 있는 상품의 가격과 보드 배치 규칙을 정의합니다.
//

enum ShopProduct: String, CaseIterable, Identifiable {
    case cookingPot

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cookingPot:
            return "냄비"
        }
    }

    var price: Int {
        switch self {
        case .cookingPot:
            return 5
        }
    }

    var boardItemKind: BoardItemKind {
        switch self {
        case .cookingPot:
            return .cookingPot
        }
    }
}
