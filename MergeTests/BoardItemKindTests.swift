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
}
