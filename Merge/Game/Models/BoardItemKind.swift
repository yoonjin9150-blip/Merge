//
//  BoardItemKind.swift
//  Merge
//
//  생성기와 재료의 종류별 규칙을 정의합니다.
//

enum BoardItemKind {
    case grainSack
    case wheat
    case flour
    case dough
    case noodle
    case riceCake

    var emoji: String {
        switch self {
        case .grainSack:
            // 곡물 포대 이미지가 준비되기 전까지 사용하는 임시 이모지입니다.
            return "🧺"
        case .wheat:
            return "🌾"
        case .flour:
            return "🥣"
        case .dough:
            // 최종 픽셀 아트가 준비되기 전까지 사용하는 임시 이모지입니다.
            return "🫓"
        case .noodle:
            return "🍜"
        case .riceCake:
            return "🍡"
        }
    }

    // 같은 재료 두 개를 머지했을 때 만들어질 다음 단계입니다.
    // 최종 단계인 떡과 생성기는 다음 단계가 없으므로 nil입니다.
    var nextKind: BoardItemKind? {
        switch self {
        case .grainSack:
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
        case .wheat, .flour, .dough, .noodle, .riceCake:
            return nil
        }
    }
}
