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

        #expect(pot.cookingToolState == .empty)
        #expect(pot.isDraggable)
        #expect(pot.loadCookingIngredient(.dough))
        #expect(pot.cookingToolState == .loaded([.dough]))
        #expect(!pot.isDraggable)
        #expect(pot.beginCooking() == .sujebi)
        #expect(pot.cookingToolState == .cooking(.sujebi))
        #expect(pot.isCooking)

        pot.finishCooking()

        #expect(pot.cookingToolState == .empty)
        #expect(pot.isDraggable)
        #expect(!pot.isCooking)
    }

    @Test
    func 조리전에는냄비에서반죽을다시꺼낼수있다() {
        let pot = makeNode(kind: .cookingPot)

        #expect(pot.loadCookingIngredient(.dough))
        #expect(pot.removeCookingIngredient() == .dough)
        #expect(pot.cookingToolState == .empty)
        #expect(pot.removeCookingIngredient() == nil)
    }

    @Test
    func 냄비에는레시피가될수있는재료만두개까지넣을수있다() {
        let pot = makeNode(kind: .cookingPot)

        #expect(pot.loadCookingIngredient(.seasoningSauce))
        #expect(!pot.loadCookingIngredient(.dough))
        #expect(pot.loadCookingIngredient(.noodle))
        #expect(pot.cookingToolState == .loaded([.seasoningSauce, .noodle]))
        #expect(pot.beginCooking() == .ramyeon)
    }

    @Test
    func 후라이팬은냄비레시피재료조합을받지않는다() {
        let fryingPan = makeNode(kind: .fryingPan)

        #expect(!fryingPan.loadCookingIngredient(.noodle))
        #expect(fryingPan.loadCookingIngredient(.dough))
        #expect(fryingPan.beginCooking() == .hotteok)
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
