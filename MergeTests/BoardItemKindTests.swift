//
//  BoardItemKindTests.swift
//  MergeTests
//
//  생성기와 곡물 재료의 단계별 규칙을 검증합니다.
//

import Testing
import UIKit
@testable import Merge

@MainActor
struct BoardItemKindTests {

    @Test
    func 곡물재료는순서대로다음단계와연결된다() {
        #expect(BoardItemKind.wheat.nextKind == .flour)
        #expect(BoardItemKind.flour.nextKind == .dough)
        #expect(BoardItemKind.dough.nextKind == .noodle)
        #expect(BoardItemKind.noodle.nextKind == .riceCake)
    }

    @Test
    func 양념재료는고추부터양념장까지순서대로연결된다() {
        #expect(BoardItemKind.chiliPepper.nextKind == .chiliPowder)
        #expect(BoardItemKind.chiliPowder.nextKind == .gochujang)
        #expect(BoardItemKind.gochujang.nextKind == .seasoningSauce)
        #expect(BoardItemKind.seasoningSauce.nextKind == nil)
    }

    @Test
    func 베이킹재료는설탕부터초콜릿까지일곱단계로연결된다() {
        #expect(BoardItemKind.sugar.nextKind == .egg)
        #expect(BoardItemKind.egg.nextKind == .milk)
        #expect(BoardItemKind.milk.nextKind == .butter)
        #expect(BoardItemKind.butter.nextKind == .whippedCream)
        #expect(BoardItemKind.whippedCream.nextKind == .cheese)
        #expect(BoardItemKind.cheese.nextKind == .chocolate)
        #expect(BoardItemKind.chocolate.nextKind == nil)
    }

    @Test
    func 떡과생성기와조리도구는다음머지단계가없다() {
        #expect(BoardItemKind.riceCake.nextKind == nil)
        #expect(BoardItemKind.grainSack.nextKind == nil)
        #expect(BoardItemKind.jangdokdae.nextKind == nil)
        #expect(BoardItemKind.cookingPot.nextKind == nil)
        #expect(BoardItemKind.fryingPan.nextKind == nil)
        #expect(BoardItemKind.sujebi.nextKind == nil)
    }

    @Test
    func 생성기별가중치에따라재료를생성한다() {
        #expect(BoardItemKind.grainSack.spawnedItemKind(randomUnit: 0.99) == .wheat)
        #expect(BoardItemKind.jangdokdae.spawnedItemKind(randomUnit: 0.99) == .chiliPepper)
        #expect(BoardItemKind.bakingCabinet.spawnedItemKind(randomUnit: 0) == .sugar)
        #expect(BoardItemKind.bakingCabinet.spawnedItemKind(randomUnit: 0.8999) == .sugar)
        #expect(BoardItemKind.bakingCabinet.spawnedItemKind(randomUnit: 0.9) == .egg)
        #expect(BoardItemKind.bakingCabinet.spawnedItemKind(randomUnit: 0.9999) == .egg)
        #expect(BoardItemKind.cookingPot.spawnedItemKind(randomUnit: 0.5) == nil)
        #expect(BoardItemKind.sugar.spawnedItemKind(randomUnit: 0.5) == nil)
    }

    @Test
    func 곡물포대와장독대와베이킹찬장만생성기로분류된다() {
        #expect(BoardItemKind.grainSack.isGenerator)
        #expect(BoardItemKind.jangdokdae.isGenerator)
        #expect(BoardItemKind.bakingCabinet.isGenerator)
        #expect(!BoardItemKind.wheat.isGenerator)
        #expect(!BoardItemKind.flour.isGenerator)
        #expect(!BoardItemKind.dough.isGenerator)
        #expect(!BoardItemKind.noodle.isGenerator)
        #expect(!BoardItemKind.riceCake.isGenerator)
        #expect(!BoardItemKind.cookingPot.isGenerator)
        #expect(!BoardItemKind.fryingPan.isGenerator)
        #expect(!BoardItemKind.sujebi.isGenerator)
        #expect(!BoardItemKind.chiliPepper.isGenerator)
    }

    @Test
    func 냄비와후라이팬은재료나생성기가아닌조리도구로분류된다() {
        #expect(BoardItemKind.cookingPot.role == .cookingTool)
        #expect(BoardItemKind.fryingPan.role == .cookingTool)
        #expect(BoardItemKind.cookingPot.isCookingTool)
        #expect(BoardItemKind.fryingPan.isCookingTool)
        #expect(!BoardItemKind.grainSack.isCookingTool)
        #expect(!BoardItemKind.wheat.isCookingTool)
    }

    @Test
    func 상점영구아이템은초기곡물포대와구분된다() {
        #expect(BoardItemKind.cookingPot.isShopPermanentItem)
        #expect(BoardItemKind.fryingPan.isShopPermanentItem)
        #expect(BoardItemKind.jangdokdae.isShopPermanentItem)
        #expect(BoardItemKind.bakingCabinet.isShopPermanentItem)
        #expect(!BoardItemKind.grainSack.isShopPermanentItem)
        #expect(!BoardItemKind.sugar.isShopPermanentItem)
    }

    @Test
    func 완성음식은머지재료가아닌음식으로분류된다() {
        let dishes: [BoardItemKind] = [
            .sujebi,
            .kalguksu,
            .ramyeon,
            .tteokbokki,
            .hotteok,
            .tteokKkochi,
            .gireumTteokbokki
        ]

        for dish in dishes {
            #expect(dish.role == .dish)
            #expect(dish.isDish)
            #expect(!dish.isCookingTool)
            #expect(!dish.isMaximumMergeLevel)
            #expect(dish.nextKind == nil)
            #expect(dish.spawnedItemKind(randomUnit: 0.5) == nil)
            #expect(dish.requiredMergeCount == nil)
        }
    }

    @Test
    func 떡과양념장과초콜릿이각머지트리의최고레벨이다() {
        #expect(BoardItemKind.riceCake.isMaximumMergeLevel)
        #expect(BoardItemKind.seasoningSauce.isMaximumMergeLevel)
        #expect(BoardItemKind.chocolate.isMaximumMergeLevel)
        #expect(!BoardItemKind.grainSack.isMaximumMergeLevel)
        #expect(!BoardItemKind.wheat.isMaximumMergeLevel)
        #expect(!BoardItemKind.flour.isMaximumMergeLevel)
        #expect(!BoardItemKind.dough.isMaximumMergeLevel)
        #expect(!BoardItemKind.noodle.isMaximumMergeLevel)
        #expect(!BoardItemKind.cookingPot.isMaximumMergeLevel)
        #expect(!BoardItemKind.fryingPan.isMaximumMergeLevel)
        #expect(!BoardItemKind.jangdokdae.isMaximumMergeLevel)
        #expect(!BoardItemKind.chiliPepper.isMaximumMergeLevel)
        #expect(!BoardItemKind.chiliPowder.isMaximumMergeLevel)
        #expect(!BoardItemKind.gochujang.isMaximumMergeLevel)
    }

    @Test
    func 현재보드아이템은모두픽셀텍스처와연결된다() {
        let expectedTextures: [(BoardItemKind, String)] = [
            (.grainSack, "GrainSackPixel"),
            (.jangdokdae, "JangdokdaePixel"),
            (.bakingCabinet, "BakingCabinetPixel"),
            (.cookingPot, "CookingPotPixel"),
            (.fryingPan, "FryingPanPixel"),
            (.wheat, "WheatPixel"),
            (.flour, "FlourPixel"),
            (.dough, "DoughPixel"),
            (.noodle, "NoodlePixel"),
            (.riceCake, "RiceCakePixel"),
            (.chiliPepper, "ChiliPepperPixel"),
            (.chiliPowder, "ChiliPowderPixel"),
            (.gochujang, "GochujangPixel"),
            (.seasoningSauce, "SeasoningSaucePixel"),
            (.sugar, "SugarPixel"),
            (.egg, "EggPixel"),
            (.milk, "MilkPixel"),
            (.butter, "ButterPixel"),
            (.whippedCream, "WhippedCreamPixel"),
            (.cheese, "CheesePixel"),
            (.chocolate, "ChocolatePixel"),
            (.sujebi, "SujebiPixel"),
            (.kalguksu, "KalguksuPixel"),
            (.ramyeon, "RamyeonPixel"),
            (.tteokbokki, "TteokbokkiPixel"),
            (.hotteok, "HotteokPixel"),
            (.tteokKkochi, "TteokKkochiPixel"),
            (.gireumTteokbokki, "GireumTteokbokkiPixel")
        ]

        for (kind, expectedTextureName) in expectedTextures {
            #expect(kind.textureName == expectedTextureName)
            #expect(UIImage(named: expectedTextureName) != nil)
        }

        #expect(UIImage(named: "CookingPotOpenPixel") != nil)
    }

    @Test
    func 곡물단계별누적머지횟수는일삼칠십오로증가한다() {
        #expect(BoardItemKind.wheat.requiredMergeCount == 0)
        #expect(BoardItemKind.flour.requiredMergeCount == 1)
        #expect(BoardItemKind.dough.requiredMergeCount == 3)
        #expect(BoardItemKind.noodle.requiredMergeCount == 7)
        #expect(BoardItemKind.riceCake.requiredMergeCount == 15)
        #expect(BoardItemKind.grainSack.requiredMergeCount == nil)
        #expect(BoardItemKind.cookingPot.requiredMergeCount == nil)
        #expect(BoardItemKind.fryingPan.requiredMergeCount == nil)
        #expect(BoardItemKind.sujebi.requiredMergeCount == nil)
        #expect(BoardItemKind.jangdokdae.requiredMergeCount == nil)
        #expect(BoardItemKind.chiliPepper.requiredMergeCount == 0)
        #expect(BoardItemKind.chiliPowder.requiredMergeCount == 1)
        #expect(BoardItemKind.gochujang.requiredMergeCount == 3)
        #expect(BoardItemKind.seasoningSauce.requiredMergeCount == 7)
        #expect(BoardItemKind.sugar.requiredMergeCount == 0)
        #expect(BoardItemKind.egg.requiredMergeCount == 1)
        #expect(BoardItemKind.milk.requiredMergeCount == 3)
        #expect(BoardItemKind.butter.requiredMergeCount == 7)
        #expect(BoardItemKind.whippedCream.requiredMergeCount == 15)
        #expect(BoardItemKind.cheese.requiredMergeCount == 31)
        #expect(BoardItemKind.chocolate.requiredMergeCount == 63)
    }

    @Test
    func 납품코인은누적머지횟수의두배이며최저삼코인이다() {
        #expect(BoardItemKind.wheat.deliveryCoinReward == nil)
        #expect(BoardItemKind.flour.deliveryCoinReward == 3)
        #expect(BoardItemKind.dough.deliveryCoinReward == 6)
        #expect(BoardItemKind.noodle.deliveryCoinReward == 14)
        #expect(BoardItemKind.riceCake.deliveryCoinReward == 30)
        #expect(BoardItemKind.grainSack.deliveryCoinReward == nil)
        #expect(BoardItemKind.cookingPot.deliveryCoinReward == nil)
        #expect(BoardItemKind.fryingPan.deliveryCoinReward == nil)
        #expect(BoardItemKind.sujebi.deliveryCoinReward == nil)
        #expect(BoardItemKind.jangdokdae.deliveryCoinReward == nil)
        #expect(BoardItemKind.chiliPepper.deliveryCoinReward == nil)
        #expect(BoardItemKind.chiliPowder.deliveryCoinReward == 3)
        #expect(BoardItemKind.gochujang.deliveryCoinReward == 6)
        #expect(BoardItemKind.seasoningSauce.deliveryCoinReward == 14)
    }
}
