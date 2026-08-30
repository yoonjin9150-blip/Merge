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

    // 상품을 상점에서 구매할 수 있게 되는 최초 챕터입니다.
    // 구매 여부와 해금 여부를 분리해 이미 산 상품은 이후에도 항상 보유 상태로 표시합니다.
    var requiredChapter: GameChapter {
        switch self {
        case .cookingPot:
            return .relightStove
        case .jangdokdae:
            return .restoreJangFlavor
        }
    }

    func isUnlocked(in chapter: GameChapter) -> Bool {
        chapter >= requiredChapter
    }

    var unlockDescription: String {
        switch self {
        case .cookingPot:
            return "게임 시작부터 구매할 수 있습니다."
        case .jangdokdae:
            return "수제비 첫 주문을 완료하면 구매할 수 있어요."
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
