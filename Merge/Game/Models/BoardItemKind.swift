//
//  BoardItemKind.swift
//  Merge
//
//  생성기와 재료의 종류별 규칙을 정의합니다.
//

enum BoardItemRole {
    case generator
    case ingredient
    case cookingTool
}

enum BoardItemKind: Hashable {
    case grainSack
    case cookingPot
    case wheat
    case flour
    case dough
    case noodle
    case riceCake

    // 각 보드 아이템과 연결된 Assets.xcassets의 픽셀 이미지 이름입니다.
    // 새 아이템을 추가할 때는 먼저 전용 픽셀 에셋을 준비한 뒤 이곳에 연결합니다.
    var textureName: String {
        switch self {
        case .grainSack:
            return "GrainSackPixel"
        case .cookingPot:
            return "CookingPotPixel"
        case .wheat:
            return "WheatPixel"
        case .flour:
            return "FlourPixel"
        case .dough:
            return "DoughPixel"
        case .noodle:
            return "NoodlePixel"
        case .riceCake:
            return "RiceCakePixel"
        }
    }

    // 각 이미지가 한 칸 안에서 차지하는 크기입니다.
    // 에셋마다 투명 여백과 형태가 달라 보드에서 비슷한 크기로 보이도록 따로 조정합니다.
    var visualScale: Double {
        switch self {
        case .grainSack:
            return 0.86
        case .cookingPot:
            return 0.92
        case .wheat:
            return 0.98
        case .flour:
            return 0.84
        case .dough:
            return 0.90
        case .noodle:
            return 0.94
        case .riceCake:
            return 0.98
        }
    }

    // 같은 재료 두 개를 머지했을 때 만들어질 다음 단계입니다.
    // 최종 단계인 떡과 생성기는 다음 단계가 없으므로 nil입니다.
    var nextKind: BoardItemKind? {
        switch self {
        case .grainSack, .cookingPot:
            return nil
        case .wheat:
            return .flour
        case .flour:
            return .dough
        case .dough:
            return .noodle
        case .noodle:
            return .riceCake
        case .riceCake:
            return nil
        }
    }

    // 생성기를 탭했을 때 만들어지는 아이템입니다.
    // 재료 아이템은 다른 아이템을 생성하지 않으므로 nil입니다.
    var spawnedItemKind: BoardItemKind? {
        switch self {
        case .grainSack:
            return .wheat
        case .cookingPot, .wheat, .flour, .dough, .noodle, .riceCake:
            return nil
        }
    }

    // 같은 보드 위에 있어도 생성기·재료·조리도구는 서로 다른 게임 규칙을 가집니다.
    // 역할을 명시해 냄비를 최고 레벨 재료나 생성기로 잘못 판단하지 않게 합니다.
    var role: BoardItemRole {
        switch self {
        case .grainSack:
            return .generator
        case .cookingPot:
            return .cookingTool
        case .wheat, .flour, .dough, .noodle, .riceCake:
            return .ingredient
        }
    }

    // 탭해 다른 아이템을 만들어 내는 생성기인지 나타냅니다.
    // 화면에서는 이 값으로 반짝임과 에너지 번개 배지를 표시합니다.
    var isGenerator: Bool {
        role == .generator
    }

    var isCookingTool: Bool {
        role == .cookingTool
    }

    // 현재 머지 트리에서 더 높은 단계로 합칠 수 없는 최종 재료인지 나타냅니다.
    // nextKind가 nil인 생성기까지 최고 레벨로 오인하지 않도록 재료 종류를 명시합니다.
    var isMaximumMergeLevel: Bool {
        switch self {
        case .riceCake:
            return true
        case .grainSack, .cookingPot, .wheat, .flour, .dough, .noodle:
            return false
        }
    }

    // 생성기에서 나오는 1단계 재료 두 개부터 이 단계 하나를 만들 때 필요한 누적 머지 횟수입니다.
    // 2단계부터 1, 3, 7, 15로 증가하며 주문 난이도와 보상 계산의 기준이 됩니다.
    var requiredMergeCount: Int? {
        switch self {
        case .grainSack, .cookingPot:
            return nil
        case .wheat:
            return 0
        case .flour:
            return 1
        case .dough:
            return 3
        case .noodle:
            return 7
        case .riceCake:
            return 15
        }
    }

    // 현재 곡물 납품 주문은 누적 머지 1회당 2코인을 지급합니다.
    // 첫 밀가루 주문은 초반 구매 루프를 열 수 있도록 최저 보상 3코인을 보장합니다.
    var deliveryCoinReward: Int? {
        guard let requiredMergeCount, requiredMergeCount > 0 else {
            return nil
        }

        return max(3, requiredMergeCount * 2)
    }
}
