//
//  MergeBoardScenePermanentItemTests.swift
//  MergeTests
//
//  영구 구매한 조리도구의 보드 배치와 복원을 검증합니다.
//

import SpriteKit
import Testing
@testable import Merge

@MainActor
struct MergeBoardScenePermanentItemTests {
    @Test
    func 구매한냄비는장면을처음그릴때첫빈칸에복원된다() {
        let scene = makeScene()
        var latestCounts: [BoardItemKind: Int] = [:]
        scene.onBoardItemCountsChanged = { latestCounts = $0 }
        scene.purchasedPermanentItemKinds = [.cookingPot]

        scene.didMove(to: SKView())

        #expect(latestCounts[.grainSack] == 1)
        #expect(latestCounts[.cookingPot] == 1)
        #expect(!scene.canPlacePermanentItem(.cookingPot))
    }

    @Test
    func 냄비는한번만배치할수있다() {
        let scene = makeScene()
        var latestCounts: [BoardItemKind: Int] = [:]
        scene.onBoardItemCountsChanged = { latestCounts = $0 }
        scene.didMove(to: SKView())

        #expect(scene.canPlacePermanentItem(.cookingPot))
        #expect(scene.placePermanentItemIfPossible(.cookingPot))
        #expect(latestCounts[.cookingPot] == 1)
        #expect(!scene.placePermanentItemIfPossible(.cookingPot))
        #expect(latestCounts[.cookingPot] == 1)
    }

    private func makeScene() -> MergeBoardScene {
        let scene = MergeBoardScene(size: CGSize(width: 390, height: 620))
        scene.scaleMode = .resizeFill
        return scene
    }
}
