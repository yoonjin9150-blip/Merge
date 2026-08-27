//
//  ShopProduct.swift
//  Merge
//
//  상점에서 구매할 수 있는 상품의 가격과 보드 배치 규칙을 정의합니다.
//

enum ShopProduct: String, CaseIterable, Identifiable {
    case cookingPot
    case jangdokdae

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cookingPot:
            return "냄비"
        case .jangdokdae:
            return "장독대"
        }
    }

    var price: Int {
        switch self {
        case .cookingPot:
            return 5
        case .jangdokdae:
            // 두 번째 재료 트리 해금 비용입니다. 플레이테스트 후 조정할 임시 가격입니다.
            return 30
        }
    }

    var boardItemKind: BoardItemKind {
        switch self {
        case .cookingPot:
            return .cookingPot
        case .jangdokdae:
            return .jangdokdae
        }
    }

    var description: String {
        switch self {
        case .cookingPot:
            return "반죽을 넣어 수제비를 만들 수 있는\n영구 조리도구예요."
        case .jangdokdae:
            return "선택한 뒤 다시 탭하면 고추를 만드는\n영구 생성기예요."
        }
    }
}
