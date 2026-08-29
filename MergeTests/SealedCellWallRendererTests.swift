//
//  SealedCellWallRendererTests.swift
//  MergeTests
//
//  봉인 벽돌이 개별 조각으로 구성되어 부서지는 연출을 실행할 수 있는지 검증합니다.
//

import SpriteKit
import Testing
@testable import Merge

@MainActor
struct SealedCellWallRendererTests {
    @Test
    func 봉인벽은흔들리고흩어질개별벽돌조각으로구성된다() {
        let renderer = SealedCellWallRenderer()
        let cover = renderer.makeCover(
            for: BoardCell(column: 2, row: 3),
            cellSize: 44
        )

        let brickCount = cover.children.filter {
            $0.name == "sealedWallBrick"
        }.count

        #expect(cover.name == "sealedCellCover")
        #expect(brickCount == 6)
        #expect(cover.childNode(withName: "sealedWallMortar") != nil)
    }
}
