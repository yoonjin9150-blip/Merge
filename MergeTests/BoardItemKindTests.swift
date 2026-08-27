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
    func 떡과생성기와조리도구는다음머지단계가없다() {
        #expect(BoardItemKind.riceCake.nextKind == nil)
        #expect(BoardItemKind.grainSack.nextKind == nil)
        #expect(BoardItemKind.jangdokdae.nextKind == nil)
        #expect(BoardItemKind.cookingPot.nextKind == nil)
        #expect(BoardItemKind.sujebi.nextKind == nil)
    }

    @Test
    func 생성기별로첫단계재료만생성한다() {
        #expect(BoardItemKind.grainSack.spawnedItemKind == .wheat)
        #expect(BoardItemKind.jangdokdae.spawnedItemKind == .chiliPepper)
        #expect(BoardItemKind.cookingPot.spawnedItemKind == nil)
        #expect(BoardItemKind.wheat.spawnedItemKind == nil)
        #expect(BoardItemKind.flour.spawnedItemKind == nil)
        #expect(BoardItemKind.dough.spawnedItemKind == nil)
        #expect(BoardItemKind.noodle.spawnedItemKind == nil)
        #expect(BoardItemKind.riceCake.spawnedItemKind == nil)
        #expect(BoardItemKind.sujebi.spawnedItemKind == nil)
        #expect(BoardItemKind.chiliPepper.spawnedItemKind == nil)
        #expect(BoardItemKind.chiliPowder.spawnedItemKind == nil)
        #expect(BoardItemKind.gochujang.spawnedItemKind == nil)
        #expect(BoardItemKind.seasoningSauce.spawnedItemKind == nil)
    }

    @Test
    func 곡물포대와장독대만생성기로분류된다() {
        #expect(BoardItemKind.grainSack.isGenerator)
        #expect(BoardItemKind.jangdokdae.isGenerator)
        #expect(!BoardItemKind.wheat.isGenerator)
        #expect(!BoardItemKind.flour.isGenerator)
        #expect(!BoardItemKind.dough.isGenerator)
        #expect(!BoardItemKind.noodle.isGenerator)
        #expect(!BoardItemKind.riceCake.isGenerator)
        #expect(!BoardItemKind.cookingPot.isGenerator)
        #expect(!BoardItemKind.sujebi.isGenerator)
        #expect(!BoardItemKind.chiliPepper.isGenerator)
    }

    @Test
    func 냄비는재료나생성기가아닌조리도구로분류된다() {
        #expect(BoardItemKind.cookingPot.role == .cookingTool)
        #expect(BoardItemKind.cookingPot.isCookingTool)
        #expect(!BoardItemKind.grainSack.isCookingTool)
        #expect(!BoardItemKind.wheat.isCookingTool)
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
            #expect(dish.spawnedItemKind == nil)
            #expect(dish.requiredMergeCount == nil)
        }
    }

    @Test
    func 떡과양념장이각머지트리의최고레벨이다() {
        #expect(BoardItemKind.riceCake.isMaximumMergeLevel)
        #expect(BoardItemKind.seasoningSauce.isMaximumMergeLevel)
        #expect(!BoardItemKind.grainSack.isMaximumMergeLevel)
        #expect(!BoardItemKind.wheat.isMaximumMergeLevel)
        #expect(!BoardItemKind.flour.isMaximumMergeLevel)
        #expect(!BoardItemKind.dough.isMaximumMergeLevel)
        #expect(!BoardItemKind.noodle.isMaximumMergeLevel)
        #expect(!BoardItemKind.cookingPot.isMaximumMergeLevel)
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
            (.cookingPot, "CookingPotPixel"),
            (.wheat, "WheatPixel"),
            (.flour, "FlourPixel"),
            (.dough, "DoughPixel"),
            (.noodle, "NoodlePixel"),
            (.riceCake, "RiceCakePixel"),
            (.chiliPepper, "ChiliPepperPixel"),
            (.chiliPowder, "ChiliPowderPixel"),
            (.gochujang, "GochujangPixel"),
            (.seasoningSauce, "SeasoningSaucePixel"),
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
        #expect(BoardItemKind.sujebi.requiredMergeCount == nil)
        #expect(BoardItemKind.jangdokdae.requiredMergeCount == nil)
        #expect(BoardItemKind.chiliPepper.requiredMergeCount == 0)
        #expect(BoardItemKind.chiliPowder.requiredMergeCount == 1)
        #expect(BoardItemKind.gochujang.requiredMergeCount == 3)
        #expect(BoardItemKind.seasoningSauce.requiredMergeCount == 7)
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
        #expect(BoardItemKind.sujebi.deliveryCoinReward == nil)
        #expect(BoardItemKind.jangdokdae.deliveryCoinReward == nil)
        #expect(BoardItemKind.chiliPepper.deliveryCoinReward == nil)
        #expect(BoardItemKind.chiliPowder.deliveryCoinReward == 3)
        #expect(BoardItemKind.gochujang.deliveryCoinReward == 6)
        #expect(BoardItemKind.seasoningSauce.deliveryCoinReward == 14)
    }
}
