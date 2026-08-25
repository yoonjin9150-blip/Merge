//
//  BoardItemNodeIndicatorTests.swift
//  MergeTests
//
//  보드 아이템 역할에 맞는 배지가 생성되는지 검증합니다.
//

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
