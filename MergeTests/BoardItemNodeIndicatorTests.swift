//
//  BoardItemNodeIndicatorTests.swift
//  MergeTests
//
//  보드 아이템 역할에 맞는 배지가 생성되는지 검증합니다.
//

import SpriteKit
import Testing
@testable import Merge

@MainActor
struct BoardItemNodeIndicatorTests {

    @Test
    func 생성기에는에너지번개배지만표시된다() {
        let generator = makeNode(kind: .grainSack)

        #expect(
            generator.childNode(withName: "generatorEnergyIndicator") != nil
        )
        #expect(
            generator.childNode(withName: "maximumLevelIndicator") == nil
        )
    }

    @Test
    func 생성기반짝임은반복액션으로실행된다() throws {
        let generator = makeNode(kind: .grainSack)
        let sparkleContainer = try #require(
            generator.childNode(withName: "generatorSparkleContainer")
        )

        #expect(sparkleContainer.children.count == 3)
        #expect(
            sparkleContainer.children.allSatisfy { $0.hasActions() }
        )
    }

    @Test
    func 최고레벨재료에는왕관배지만표시된다() {
        let maximumLevelItem = makeNode(kind: .riceCake)

        #expect(
            maximumLevelItem.childNode(withName: "maximumLevelIndicator") != nil
        )
        #expect(
            maximumLevelItem.childNode(withName: "generatorEnergyIndicator") == nil
        )
    }

    @Test
    func 일반재료에는역할배지가표시되지않는다() {
        let ingredient = makeNode(kind: .wheat)

        #expect(
            ingredient.childNode(withName: "generatorEnergyIndicator") == nil
        )
        #expect(
            ingredient.childNode(withName: "maximumLevelIndicator") == nil
        )
        #expect(
            ingredient.childNode(withName: "generatorSparkleContainer") == nil
        )
    }

    private func makeNode(kind: BoardItemKind) -> BoardItemNode {
        let node = BoardItemNode(
            kind: kind,
            cell: BoardCell(column: 0, row: 0)
        )
        node.configureAppearance(cellSize: 48)
        return node
    }
}
