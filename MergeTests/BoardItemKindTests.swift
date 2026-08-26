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
    func 떡과생성기는다음머지단계가없다() {
        #expect(BoardItemKind.riceCake.nextKind == nil)
        #expect(BoardItemKind.grainSack.nextKind == nil)
    }

    @Test
    func 곡물포대만밀을생성한다() {
        #expect(BoardItemKind.grainSack.spawnedItemKind == .wheat)
        #expect(BoardItemKind.wheat.spawnedItemKind == nil)
        #expect(BoardItemKind.flour.spawnedItemKind == nil)
        #expect(BoardItemKind.dough.spawnedItemKind == nil)
        #expect(BoardItemKind.noodle.spawnedItemKind == nil)
        #expect(BoardItemKind.riceCake.spawnedItemKind == nil)
    }

    @Test
    func 곡물포대만생성기로분류된다() {
        #expect(BoardItemKind.grainSack.isGenerator)
        #expect(!BoardItemKind.wheat.isGenerator)
        #expect(!BoardItemKind.flour.isGenerator)
        #expect(!BoardItemKind.dough.isGenerator)
        #expect(!BoardItemKind.noodle.isGenerator)
        #expect(!BoardItemKind.riceCake.isGenerator)
    }

    @Test
    func 떡만현재머지트리의최고레벨이다() {
        #expect(BoardItemKind.riceCake.isMaximumMergeLevel)
        #expect(!BoardItemKind.grainSack.isMaximumMergeLevel)
        #expect(!BoardItemKind.wheat.isMaximumMergeLevel)
        #expect(!BoardItemKind.flour.isMaximumMergeLevel)
        #expect(!BoardItemKind.dough.isMaximumMergeLevel)
        #expect(!BoardItemKind.noodle.isMaximumMergeLevel)
    }

    @Test
    func 현재보드아이템은모두픽셀텍스처와연결된다() {
        let expectedTextures: [(BoardItemKind, String)] = [
            (.grainSack, "GrainSackPixel"),
            (.wheat, "WheatPixel"),
            (.flour, "FlourPixel"),
            (.dough, "DoughPixel"),
            (.noodle, "NoodlePixel"),
            (.riceCake, "RiceCakePixel")
        ]

        for (kind, expectedTextureName) in expectedTextures {
            #expect(kind.textureName == expectedTextureName)
            #expect(UIImage(named: expectedTextureName) != nil)
        }
    }

    @Test
    func 곡물단계별누적머지횟수는일삼칠십오로증가한다() {
        #expect(BoardItemKind.wheat.requiredMergeCount == 0)
        #expect(BoardItemKind.flour.requiredMergeCount == 1)
        #expect(BoardItemKind.dough.requiredMergeCount == 3)
        #expect(BoardItemKind.noodle.requiredMergeCount == 7)
        #expect(BoardItemKind.riceCake.requiredMergeCount == 15)
        #expect(BoardItemKind.grainSack.requiredMergeCount == nil)
    }

    @Test
    func 납품코인은누적머지횟수의두배이며최저삼코인이다() {
        #expect(BoardItemKind.wheat.deliveryCoinReward == nil)
        #expect(BoardItemKind.flour.deliveryCoinReward == 3)
        #expect(BoardItemKind.dough.deliveryCoinReward == 6)
        #expect(BoardItemKind.noodle.deliveryCoinReward == 14)
        #expect(BoardItemKind.riceCake.deliveryCoinReward == 30)
        #expect(BoardItemKind.grainSack.deliveryCoinReward == nil)
    }
}
