//
//  CookingRecipeTests.swift
//  MergeTests
//
//  조리도구별 재료 조합과 완성 음식 규칙을 검증합니다.
//

import Testing
@testable import Merge

@MainActor
struct CookingRecipeTests {
    @Test
    func 냄비레시피는수제비칼국수라면떡볶이로구성된다() {
        let recipes = CookingRecipe.allCases.filter {
            $0.toolKind == .cookingPot
        }

        #expect(recipes == [.sujebi, .kalguksu, .ramyeon, .tteokbokki])
        #expect(CookingRecipe.sujebi.ingredientKinds == [.dough])
        #expect(CookingRecipe.kalguksu.ingredientKinds == [.noodle])
        #expect(CookingRecipe.ramyeon.ingredientKinds == [.noodle, .seasoningSauce])
        #expect(CookingRecipe.tteokbokki.ingredientKinds == [.riceCake, .seasoningSauce])
    }

    @Test
    func 후라이팬레시피는호떡떡꼬치기름떡볶이로구성된다() {
        let recipes = CookingRecipe.allCases.filter {
            $0.toolKind == .fryingPan
        }

        #expect(recipes == [.hotteok, .tteokKkochi, .gireumTteokbokki])
        #expect(CookingRecipe.hotteok.ingredientKinds == [.dough])
        #expect(CookingRecipe.tteokKkochi.ingredientKinds == [.riceCake, .gochujang])
        #expect(CookingRecipe.gireumTteokbokki.ingredientKinds == [.riceCake, .seasoningSauce])
    }

    @Test
    func 재료를넣은순서와관계없이같은레시피를찾는다() {
        #expect(
            CookingRecipe.matching(
                toolKind: .cookingPot,
                ingredientKinds: [.seasoningSauce, .noodle]
            ) == .ramyeon
        )
        #expect(
            CookingRecipe.matching(
                toolKind: .fryingPan,
                ingredientKinds: [.gochujang, .riceCake]
            ) == .tteokKkochi
        )
    }

    @Test
    func 완성레시피의일부인재료만조리도구에추가할수있다() {
        #expect(CookingRecipe.canAdd(.seasoningSauce, to: [], in: .cookingPot))
        #expect(CookingRecipe.canAdd(.noodle, to: [.seasoningSauce], in: .cookingPot))
        #expect(!CookingRecipe.canAdd(.dough, to: [.seasoningSauce], in: .cookingPot))
        #expect(!CookingRecipe.canAdd(.noodle, to: [], in: .fryingPan))
        #expect(!CookingRecipe.canAdd(.dough, to: [.dough], in: .fryingPan))
    }

    @Test
    func 재료가부족하거나도구가다르면완성레시피가아니다() {
        #expect(
            CookingRecipe.matching(
                toolKind: .cookingPot,
                ingredientKinds: [.seasoningSauce]
            ) == nil
        )
        #expect(
            CookingRecipe.matching(
                toolKind: .fryingPan,
                ingredientKinds: [.noodle, .seasoningSauce]
            ) == nil
        )
    }

    @Test
    func 양념요리주문은조리도구와장독대를모두구매해야해금된다() {
        #expect(CookingRecipe.sujebi.isUnlocked(by: [.cookingPot]))
        #expect(CookingRecipe.kalguksu.isUnlocked(by: [.cookingPot]))
        #expect(!CookingRecipe.ramyeon.isUnlocked(by: [.cookingPot]))
        #expect(
            CookingRecipe.ramyeon.isUnlocked(
                by: [.cookingPot, .jangdokdae]
            )
        )
        #expect(CookingRecipe.hotteok.isUnlocked(by: [.fryingPan]))
        #expect(!CookingRecipe.tteokKkochi.isUnlocked(by: [.fryingPan]))
        #expect(
            CookingRecipe.tteokKkochi.isUnlocked(
                by: [.fryingPan, .jangdokdae]
            )
        )
    }
}
