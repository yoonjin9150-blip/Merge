//
//  CookingRecipe.swift
//  Merge
//
//  조리도구와 재료 조합에 따라 만들어지는 완성 음식을 정의합니다.
//

enum CookingRecipe: CaseIterable, Hashable {
    case sujebi
    case kalguksu
    case ramyeon
    case tteokbokki
    case hotteok
    case tteokKkochi
    case gireumTteokbokki

    var title: String {
        switch self {
        case .sujebi:
            return "수제비"
        case .kalguksu:
            return "칼국수"
        case .ramyeon:
            return "라면"
        case .tteokbokki:
            return "떡볶이"
        case .hotteok:
            return "호떡"
        case .tteokKkochi:
            return "떡꼬치"
        case .gireumTteokbokki:
            return "기름떡볶이"
        }
    }

    var toolKind: BoardItemKind {
        switch self {
        case .sujebi, .kalguksu, .ramyeon, .tteokbokki:
            return .cookingPot
        case .hotteok, .tteokKkochi, .gireumTteokbokki:
            return .fryingPan
        }
    }

    var ingredientKinds: [BoardItemKind] {
        switch self {
        case .sujebi, .hotteok:
            return [.dough]
        case .kalguksu:
            return [.noodle]
        case .ramyeon:
            return [.noodle, .seasoningSauce]
        case .tteokbokki, .gireumTteokbokki:
            return [.riceCake, .seasoningSauce]
        case .tteokKkochi:
            return [.riceCake, .gochujang]
        }
    }

    var resultKind: BoardItemKind {
        switch self {
        case .sujebi:
            return .sujebi
        case .kalguksu:
            return .kalguksu
        case .ramyeon:
            return .ramyeon
        case .tteokbokki:
            return .tteokbokki
        case .hotteok:
            return .hotteok
        case .tteokKkochi:
            return .tteokKkochi
        case .gireumTteokbokki:
            return .gireumTteokbokki
        }
    }

    var orderTemplateID: String {
        switch self {
        case .sujebi:
            return "sujebi-order"
        case .kalguksu:
            return "kalguksu-order"
        case .ramyeon:
            return "ramyeon-order"
        case .tteokbokki:
            return "tteokbokki-order"
        case .hotteok:
            return "hotteok-order"
        case .tteokKkochi:
            return "tteok-kkochi-order"
        case .gireumTteokbokki:
            return "gireum-tteokbokki-order"
        }
    }

    var coinReward: Int {
        switch self {
        case .sujebi, .hotteok:
            return 9
        case .kalguksu:
            return 14
        case .ramyeon:
            return 42
        case .tteokKkochi:
            return 54
        case .tteokbokki, .gireumTteokbokki:
            return 66
        }
    }

    var requiredShopProducts: Set<ShopProduct> {
        switch self {
        case .sujebi, .kalguksu:
            return [.cookingPot]
        case .ramyeon, .tteokbokki:
            return [.cookingPot, .jangdokdae]
        case .hotteok:
            return [.fryingPan]
        case .tteokKkochi, .gireumTteokbokki:
            return [.fryingPan, .jangdokdae]
        }
    }

    func isUnlocked(by purchasedProducts: Set<ShopProduct>) -> Bool {
        requiredShopProducts.isSubset(of: purchasedProducts)
    }

    func matches(
        toolKind: BoardItemKind,
        ingredientKinds: [BoardItemKind]
    ) -> Bool {
        self.toolKind == toolKind
            && Self.counts(for: self.ingredientKinds)
                == Self.counts(for: ingredientKinds)
    }

    static func matching(
        toolKind: BoardItemKind,
        ingredientKinds: [BoardItemKind]
    ) -> CookingRecipe? {
        allCases.first {
            $0.matches(toolKind: toolKind, ingredientKinds: ingredientKinds)
        }
    }

    // 현재 내용물에 새 재료를 더한 조합이 하나 이상의 레시피에 포함될 때만 투입을 허용합니다.
    // 그래서 양념장을 먼저 넣은 뒤 면이나 떡을 넣는 순서도 사용할 수 있습니다.
    static func canAdd(
        _ ingredientKind: BoardItemKind,
        to currentIngredientKinds: [BoardItemKind],
        in toolKind: BoardItemKind
    ) -> Bool {
        let proposedCounts = counts(
            for: currentIngredientKinds + [ingredientKind]
        )

        return allCases.contains { recipe in
            guard recipe.toolKind == toolKind else {
                return false
            }

            let recipeCounts = counts(for: recipe.ingredientKinds)
            return proposedCounts.allSatisfy { kind, count in
                count <= recipeCounts[kind, default: 0]
            }
        }
    }

    private static func counts(
        for ingredientKinds: [BoardItemKind]
    ) -> [BoardItemKind: Int] {
        ingredientKinds.reduce(into: [:]) { result, kind in
            result[kind, default: 0] += 1
        }
    }
}
