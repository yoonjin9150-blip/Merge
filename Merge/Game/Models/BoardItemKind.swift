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
    case dish
}

struct GeneratorSpawnOption: Equatable {
    let kind: BoardItemKind
    let weight: Double
}

enum BoardItemKind: String, Codable, Hashable {
    case grainSack
    case jangdokdae
    case bakingCabinet
    case cookingPot
    case fryingPan
    case wheat
    case flour
    case dough
    case noodle
    case riceCake
    case chiliPepper
    case chiliPowder
    case gochujang
    case seasoningSauce
    case sugar
    case egg
    case milk
    case butter
    case whippedCream
    case cheese
    case chocolate
    case sujebi
    case kalguksu
    case ramyeon
    case tteokbokki
    case hotteok
    case tteokKkochi
    case gireumTteokbokki

    // 각 보드 아이템과 연결된 Assets.xcassets의 픽셀 이미지 이름입니다.
    // 새 아이템을 추가할 때는 먼저 전용 픽셀 에셋을 준비한 뒤 이곳에 연결합니다.
    var textureName: String {
        switch self {
        case .grainSack:
            return "GrainSackPixel"
        case .jangdokdae:
            return "JangdokdaePixel"
        case .bakingCabinet:
            return "BakingCabinetPixel"
        case .cookingPot:
            return "CookingPotPixel"
        case .fryingPan:
            return "FryingPanPixel"
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
        case .chiliPepper:
            return "ChiliPepperPixel"
        case .chiliPowder:
            return "ChiliPowderPixel"
        case .gochujang:
            return "GochujangPixel"
        case .seasoningSauce:
            return "SeasoningSaucePixel"
        case .sugar:
            return "SugarPixel"
        case .egg:
            return "EggPixel"
        case .milk:
            return "MilkPixel"
        case .butter:
            return "ButterPixel"
        case .whippedCream:
            return "WhippedCreamPixel"
        case .cheese:
            return "CheesePixel"
        case .chocolate:
            return "ChocolatePixel"
        case .sujebi:
            return "SujebiPixel"
        case .kalguksu:
            return "KalguksuPixel"
        case .ramyeon:
            return "RamyeonPixel"
        case .tteokbokki:
            return "TteokbokkiPixel"
        case .hotteok:
            return "HotteokPixel"
        case .tteokKkochi:
            return "TteokKkochiPixel"
        case .gireumTteokbokki:
            return "GireumTteokbokkiPixel"
        }
    }

    var displayName: String {
        switch self {
        case .grainSack:
            return "곡물 포대"
        case .jangdokdae:
            return "장독대"
        case .bakingCabinet:
            return "베이킹 찬장"
        case .cookingPot:
            return "냄비"
        case .fryingPan:
            return "후라이팬"
        case .wheat:
            return "밀"
        case .flour:
            return "밀가루"
        case .dough:
            return "반죽"
        case .noodle:
            return "면"
        case .riceCake:
            return "떡"
        case .chiliPepper:
            return "고추"
        case .chiliPowder:
            return "고춧가루"
        case .gochujang:
            return "고추장"
        case .seasoningSauce:
            return "양념장"
        case .sugar:
            return "설탕"
        case .egg:
            return "달걀"
        case .milk:
            return "우유"
        case .butter:
            return "버터"
        case .whippedCream:
            return "생크림"
        case .cheese:
            return "치즈"
        case .chocolate:
            return "초콜릿"
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

    // 냄비는 재료를 넣기 전 열린 이미지를 사용하고, 후라이팬은 기본 이미지를 그대로 사용합니다.
    var textureNameForIdleCookingTool: String {
        self == .cookingPot ? "CookingPotOpenPixel" : textureName
    }

    // 각 이미지가 한 칸 안에서 차지하는 크기입니다.
    // 에셋마다 투명 여백과 형태가 달라 보드에서 비슷한 크기로 보이도록 따로 조정합니다.
    var visualScale: Double {
        switch self {
        case .grainSack:
            return 0.86
        case .jangdokdae, .bakingCabinet:
            return 0.88
        case .cookingPot, .fryingPan:
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
        case .chiliPepper:
            return 0.94
        case .chiliPowder, .gochujang, .seasoningSauce:
            return 0.92
        case .sugar, .egg, .milk, .butter, .whippedCream, .cheese, .chocolate:
            return 0.94
        case .sujebi, .kalguksu, .ramyeon, .tteokbokki, .hotteok,
             .tteokKkochi, .gireumTteokbokki:
            return 0.94
        }
    }

    // 같은 재료 두 개를 머지했을 때 만들어질 다음 단계입니다.
    // 각 트리의 최종 단계와 생성기·조리도구·완성 음식은 다음 단계가 없으므로 nil입니다.
    var nextKind: BoardItemKind? {
        switch self {
        case .grainSack, .jangdokdae, .bakingCabinet, .cookingPot, .fryingPan,
             .seasoningSauce, .chocolate,
             .sujebi, .kalguksu, .ramyeon, .tteokbokki, .hotteok,
             .tteokKkochi, .gireumTteokbokki:
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
        case .chiliPepper:
            return .chiliPowder
        case .chiliPowder:
            return .gochujang
        case .gochujang:
            return .seasoningSauce
        case .sugar:
            return .egg
        case .egg:
            return .milk
        case .milk:
            return .butter
        case .butter:
            return .whippedCream
        case .whippedCream:
            return .cheese
        case .cheese:
            return .chocolate
        }
    }

    // 생성기별 결과 후보와 상대 가중치입니다.
    // 한 종류만 만드는 기존 생성기도 같은 데이터 구조를 사용해 새 생성기를 쉽게 추가할 수 있습니다.
    var generatorSpawnOptions: [GeneratorSpawnOption] {
        switch self {
        case .grainSack:
            return [GeneratorSpawnOption(kind: .wheat, weight: 1)]
        case .jangdokdae:
            return [GeneratorSpawnOption(kind: .chiliPepper, weight: 1)]
        case .bakingCabinet:
            return [
                GeneratorSpawnOption(kind: .sugar, weight: 0.9),
                GeneratorSpawnOption(kind: .egg, weight: 0.1)
            ]
        case .cookingPot, .fryingPan, .wheat, .flour, .dough, .noodle, .riceCake,
             .chiliPepper, .chiliPowder, .gochujang, .seasoningSauce,
             .sugar, .egg, .milk, .butter, .whippedCream, .cheese, .chocolate,
             .sujebi, .kalguksu, .ramyeon, .tteokbokki, .hotteok,
             .tteokKkochi, .gireumTteokbokki:
            return []
        }
    }

    // 0..<1의 난수를 가중치 구간에 대응시켜 실제 생성 결과를 선택합니다.
    // 테스트에서는 값을 직접 넣고, 게임 실행 중에는 Double.random으로 호출합니다.
    func spawnedItemKind(randomUnit: Double) -> BoardItemKind? {
        let validOptions = generatorSpawnOptions.filter { $0.weight > 0 }
        let totalWeight = validOptions.reduce(0) { $0 + $1.weight }

        guard totalWeight > 0 else {
            return nil
        }

        let clampedUnit = min(max(randomUnit, 0), 1.0.nextDown)
        let targetWeight = clampedUnit * totalWeight
        var accumulatedWeight = 0.0

        for option in validOptions {
            accumulatedWeight += option.weight

            if targetWeight < accumulatedWeight {
                return option.kind
            }
        }

        return validOptions.last?.kind
    }

    // 같은 보드 위에 있어도 생성기·재료·조리도구는 서로 다른 게임 규칙을 가집니다.
    // 역할을 명시해 냄비를 최고 레벨 재료나 생성기로 잘못 판단하지 않게 합니다.
    var role: BoardItemRole {
        switch self {
        case .grainSack, .jangdokdae, .bakingCabinet:
            return .generator
        case .cookingPot, .fryingPan:
            return .cookingTool
        case .sujebi, .kalguksu, .ramyeon, .tteokbokki, .hotteok,
             .tteokKkochi, .gireumTteokbokki:
            return .dish
        case .wheat, .flour, .dough, .noodle, .riceCake,
             .chiliPepper, .chiliPowder, .gochujang, .seasoningSauce,
             .sugar, .egg, .milk, .butter, .whippedCream, .cheese, .chocolate:
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

    // 상점에서 한 번 구매한 뒤 보드와 저장 데이터에 영구히 남는 아이템입니다.
    // 시작부터 주어지는 곡물 포대는 생성기지만 상점 상품은 아니므로 제외합니다.
    var isShopPermanentItem: Bool {
        switch self {
        case .jangdokdae, .bakingCabinet, .cookingPot, .fryingPan:
            return true
        case .grainSack, .wheat, .flour, .dough, .noodle, .riceCake,
             .chiliPepper, .chiliPowder, .gochujang, .seasoningSauce,
             .sugar, .egg, .milk, .butter, .whippedCream, .cheese, .chocolate,
             .sujebi, .kalguksu, .ramyeon, .tteokbokki, .hotteok,
             .tteokKkochi, .gireumTteokbokki:
            return false
        }
    }

    // 조리를 통해 만들어져 주문에 납품할 수 있지만 서로 머지하지 않는 완성 음식입니다.
    var isDish: Bool {
        role == .dish
    }

    // 현재 머지 트리에서 더 높은 단계로 합칠 수 없는 최종 재료인지 나타냅니다.
    // nextKind가 nil인 생성기까지 최고 레벨로 오인하지 않도록 재료 종류를 명시합니다.
    var isMaximumMergeLevel: Bool {
        switch self {
        case .riceCake, .seasoningSauce, .chocolate:
            return true
        case .grainSack, .jangdokdae, .bakingCabinet, .cookingPot, .fryingPan,
             .wheat, .flour, .dough,
             .noodle, .chiliPepper, .chiliPowder, .gochujang,
             .sugar, .egg, .milk, .butter, .whippedCream, .cheese,
             .sujebi, .kalguksu, .ramyeon, .tteokbokki, .hotteok,
             .tteokKkochi, .gireumTteokbokki:
            return false
        }
    }

    // 선택 정보와 머지 트리 팝업이 함께 사용하는 전체 재료 단계입니다.
    // 생성기를 선택하면 생성 가능한 재료 트리를, 재료를 선택하면 자신이 속한 전체 트리를 반환합니다.
    var mergeTreeKinds: [BoardItemKind] {
        switch self {
        case .grainSack, .wheat, .flour, .dough, .noodle, .riceCake:
            return [.wheat, .flour, .dough, .noodle, .riceCake]
        case .jangdokdae, .chiliPepper, .chiliPowder, .gochujang, .seasoningSauce:
            return [.chiliPepper, .chiliPowder, .gochujang, .seasoningSauce]
        case .bakingCabinet, .sugar, .egg, .milk, .butter, .whippedCream, .cheese,
             .chocolate:
            return [.sugar, .egg, .milk, .butter, .whippedCream, .cheese, .chocolate]
        case .cookingPot, .fryingPan, .sujebi, .kalguksu, .ramyeon, .tteokbokki,
             .hotteok, .tteokKkochi, .gireumTteokbokki:
            return []
        }
    }

    var mergeTreeTitle: String? {
        switch self {
        case .grainSack, .wheat, .flour, .dough, .noodle, .riceCake:
            return "곡물 재료"
        case .jangdokdae, .chiliPepper, .chiliPowder, .gochujang, .seasoningSauce:
            return "장 재료"
        case .bakingCabinet, .sugar, .egg, .milk, .butter, .whippedCream, .cheese,
             .chocolate:
            return "베이킹 재료"
        case .cookingPot, .fryingPan, .sujebi, .kalguksu, .ramyeon, .tteokbokki,
             .hotteok, .tteokKkochi, .gireumTteokbokki:
            return nil
        }
    }

    var mergeTreeGeneratorKind: BoardItemKind? {
        switch self {
        case .grainSack, .wheat, .flour, .dough, .noodle, .riceCake:
            return .grainSack
        case .jangdokdae, .chiliPepper, .chiliPowder, .gochujang, .seasoningSauce:
            return .jangdokdae
        case .bakingCabinet, .sugar, .egg, .milk, .butter, .whippedCream, .cheese,
             .chocolate:
            return .bakingCabinet
        case .cookingPot, .fryingPan, .sujebi, .kalguksu, .ramyeon, .tteokbokki,
             .hotteok, .tteokKkochi, .gireumTteokbokki:
            return nil
        }
    }

    var informationTitle: String {
        switch role {
        case .generator:
            return "\(displayName) · 생성기"
        case .cookingTool:
            return "\(displayName) · 조리도구"
        case .dish:
            return "\(displayName) · 완성 음식"
        case .ingredient:
            guard let stageIndex = mergeTreeKinds.firstIndex(of: self) else {
                return displayName
            }

            return "\(displayName) · \(stageIndex + 1)단계"
        }
    }

    // 판매는 주문 대신 보드를 정리할 때 쓰는 보조 수단이므로 납품 보상보다 낮게 책정합니다.
    // 영구 생성기와 조리도구는 진행 상태가 사라지지 않도록 판매할 수 없습니다.
    var salePrice: Int? {
        switch role {
        case .generator, .cookingTool:
            return nil
        case .dish:
            return 3
        case .ingredient:
            guard let stageIndex = mergeTreeKinds.firstIndex(of: self) else {
                return nil
            }

            switch stageIndex + 1 {
            case 1...3:
                return 1
            case 4...5:
                return 2
            case 6:
                return 4
            default:
                return 6
            }
        }
    }

    var informationDescription: String {
        switch role {
        case .generator:
            switch self {
            case .grainSack:
                return "탭하면 밀을 만드는 생성기예요."
            case .jangdokdae:
                return "탭하면 고추를 만드는 생성기예요."
            case .bakingCabinet:
                return "탭하면 설탕 또는 달걀을 만드는 생성기예요."
            default:
                preconditionFailure("생성기 설명이 정의되지 않았습니다.")
            }

        case .cookingTool:
            return "재료를 넣고 요리해 완성 음식을 만드는 영구 조리도구예요."

        case .dish:
            return "조리도구로 만든 완성 음식이에요. 준비된 주문에 납품할 수 있어요."

        case .ingredient:
            guard let stageIndex = mergeTreeKinds.firstIndex(of: self) else {
                return "같은 재료 두 개를 합쳐 다음 단계로 만들 수 있어요."
            }

            let stageText = "\(stageIndex + 1)/\(mergeTreeKinds.count)단계"
            if let nextKind {
                return "\(stageText) · 같은 \(displayName) 두 개를 합치면 \(nextKind.displayName)이 돼요."
            }

            return "\(stageText) · 이 머지 트리의 최고 단계 재료예요."
        }
    }

    // 생성기에서 나오는 1단계 재료 두 개부터 이 단계 하나를 만들 때 필요한 누적 머지 횟수입니다.
    // 2단계부터 1, 3, 7, 15, 31, 63으로 증가하며 주문 난이도와 보상 계산의 기준이 됩니다.
    var requiredMergeCount: Int? {
        switch self {
        case .grainSack, .jangdokdae, .bakingCabinet, .cookingPot, .fryingPan,
             .sujebi, .kalguksu, .ramyeon, .tteokbokki, .hotteok,
             .tteokKkochi, .gireumTteokbokki:
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
        case .chiliPepper:
            return 0
        case .chiliPowder:
            return 1
        case .gochujang:
            return 3
        case .seasoningSauce:
            return 7
        case .sugar:
            return 0
        case .egg:
            return 1
        case .milk:
            return 3
        case .butter:
            return 7
        case .whippedCream:
            return 15
        case .cheese:
            return 31
        case .chocolate:
            return 63
        }
    }

    // 재료 납품 주문은 누적 머지 1회당 2코인을 지급합니다.
    // 첫 밀가루 주문은 초반 구매 루프를 열 수 있도록 최저 보상 3코인을 보장합니다.
    var deliveryCoinReward: Int? {
        guard let requiredMergeCount, requiredMergeCount > 0 else {
            return nil
        }

        return max(3, requiredMergeCount * 2)
    }
}
