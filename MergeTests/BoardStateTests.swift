//
//  BoardStateTests.swift
//  MergeTests
//
//  보드의 칸별 상태 규칙을 검증합니다.
//

import Testing
@testable import Merge

@MainActor
struct BoardStateTests {

    @Test
    func 곡물포대다음첫빈칸은첫행두번째칸이다() {
        let boardState = BoardState(columns: 7, rows: 9)
        let generatorCell = BoardCell(column: 0, row: 0)
        let generator = BoardItemNode(kind: .grainSack, cell: generatorCell)

        boardState.add(generator, at: generatorCell)

        #expect(boardState.firstEmptyCell() == BoardCell(column: 1, row: 0))
    }

    @Test
    func 도착대기중인스폰아이템도목표칸을점유한다() {
        let boardState = BoardState(columns: 7, rows: 9)
        let generatorCell = BoardCell(column: 0, row: 0)
        let reservedCell = BoardCell(column: 1, row: 0)
        let generator = BoardItemNode(kind: .grainSack, cell: generatorCell)
        let awaitingWheat = BoardItemNode(kind: .wheat, cell: reservedCell)

        awaitingWheat.isAwaitingSpawnArrival = true
        boardState.add(generator, at: generatorCell)
        boardState.add(awaitingWheat, at: reservedCell)

        #expect(boardState.item(at: reservedCell) === awaitingWheat)
        #expect(boardState.firstEmptyCell() == BoardCell(column: 2, row: 0))
    }

    @Test
    func 빈칸으로이동하면시작칸은비고목표칸을차지한다() {
        let boardState = BoardState(columns: 7, rows: 9)
        let startCell = BoardCell(column: 0, row: 0)
        let targetCell = BoardCell(column: 2, row: 1)
        let wheat = BoardItemNode(kind: .wheat, cell: startCell)

        boardState.add(wheat, at: startCell)
        boardState.move(wheat, from: startCell, to: targetCell)

        #expect(boardState.item(at: startCell) == nil)
        #expect(boardState.item(at: targetCell) === wheat)
        #expect(wheat.cell == targetCell)
    }

    @Test
    func 두아이템을교체하면칸과아이템주소가함께바뀐다() {
        let boardState = BoardState(columns: 7, rows: 9)
        let firstCell = BoardCell(column: 0, row: 0)
        let secondCell = BoardCell(column: 1, row: 0)
        let generator = BoardItemNode(kind: .grainSack, cell: firstCell)
        let wheat = BoardItemNode(kind: .wheat, cell: secondCell)

        boardState.add(generator, at: firstCell)
        boardState.add(wheat, at: secondCell)
        boardState.swap(generator, at: firstCell, with: wheat, at: secondCell)

        #expect(boardState.item(at: firstCell) === wheat)
        #expect(boardState.item(at: secondCell) === generator)
        #expect(generator.cell == secondCell)
        #expect(wheat.cell == firstCell)
    }

    @Test
    func 모든칸이차면첫빈칸이없다() {
        let columns = 7
        let rows = 9
        let boardState = BoardState(columns: columns, rows: rows)

        for row in 0..<rows {
            for column in 0..<columns {
                let cell = BoardCell(column: column, row: row)
                let item = BoardItemNode(kind: .wheat, cell: cell)
                boardState.add(item, at: cell)
            }
        }

        #expect(boardState.itemCount == columns * rows)
        #expect(boardState.firstEmptyCell() == nil)
    }
}
