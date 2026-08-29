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

    @Test
    func 잠긴재료는바위표시가생기고드래그할수없다() {
        let lockedWheat = makeNode(kind: .wheat, isLocked: true)
        let lockedIndicator = lockedWheat.childNode(
            withName: "lockedItemIndicator"
        )

        #expect(lockedWheat.isLocked)
        #expect(!lockedWheat.isDraggable)
        #expect(lockedIndicator is SKSpriteNode)
    }

    @Test
    func 일반재료는잠금표시가없고드래그할수있다() {
        let wheat = makeNode(kind: .wheat)

        #expect(!wheat.isLocked)
        #expect(wheat.isDraggable)
        #expect(
            wheat.childNode(withName: "lockedItemIndicator") == nil
        )
    }

    @Test
    func 빈냄비에반죽을넣으면고정되고조리후다시이동할수있다() {
        let pot = makeNode(kind: .cookingPot)

        #expect(pot.cookingPotState == .empty)
        #expect(pot.isDraggable)
        #expect(pot.loadCookingIngredient(.dough))
        #expect(pot.cookingPotState == .loaded(.dough))
        #expect(!pot.isDraggable)
        #expect(pot.beginCooking())
        #expect(pot.cookingPotState == .cooking(.dough))
        #expect(pot.isCooking)

        pot.finishCooking()

        #expect(pot.cookingPotState == .empty)
        #expect(pot.isDraggable)
        #expect(!pot.isCooking)
    }

    @Test
    func 조리전에는냄비에서반죽을다시꺼낼수있다() {
        let pot = makeNode(kind: .cookingPot)

        #expect(pot.loadCookingIngredient(.dough))
        #expect(pot.removeCookingIngredient() == .dough)
        #expect(pot.cookingPotState == .empty)
        #expect(pot.removeCookingIngredient() == nil)
    }

    private func makeNode(
        kind: BoardItemKind,
        isLocked: Bool = false
    ) -> BoardItemNode {
        let node = BoardItemNode(
            kind: kind,
            cell: BoardCell(column: 0, row: 0),
            isLocked: isLocked
        )
        node.configureAppearance(cellSize: 48)
        return node
    }
}
