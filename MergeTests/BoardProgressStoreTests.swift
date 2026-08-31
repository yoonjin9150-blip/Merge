//
//  BoardProgressStoreTests.swift
//  MergeTests
//
//  칸 해제 상태와 아이템 위치의 저장·복원을 검증합니다.
//

import Foundation
import SpriteKit
import Testing
@testable import Merge

@MainActor
struct BoardProgressStoreTests {
    @Test
    func 저장한봉인바위개방상태와아이템을복원한다() throws {
        let suiteName = "BoardProgressStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = BoardProgressStore(defaults: defaults)
        let snapshot = BoardProgressSnapshot(
            layoutVersion: 3,
            cells: [
                BoardCellSnapshot(
                    cell: BoardCell(column: 0, row: 0),
                    state: .open,
                    itemKind: .grainSack,
                    loadedCookingIngredientKind: nil
                ),
                BoardCellSnapshot(
                    cell: BoardCell(column: 1, row: 0),
                    state: .rockBlocked,
                    itemKind: .wheat,
                    loadedCookingIngredientKind: nil
                ),
                BoardCellSnapshot(
                    cell: BoardCell(column: 2, row: 0),
                    state: .sealed,
                    itemKind: nil,
                    loadedCookingIngredientKind: nil
                )
            ]
        )

        store.save(snapshot)

        #expect(store.load(expectedLayoutVersion: 3) == snapshot)
    }

    @Test
    func 배치버전이다르면이전보드상태를사용하지않는다() throws {
        let suiteName = "BoardProgressStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = BoardProgressStore(defaults: defaults)
        store.save(BoardProgressSnapshot(layoutVersion: 1, cells: []))

        #expect(store.load(expectedLayoutVersion: 2) == nil)
    }

    @Test
    func 두재료를넣은조리도구도투입순서와함께복원한다() throws {
        let suiteName = "BoardProgressStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = BoardProgressStore(defaults: defaults)
        let cellSnapshot = BoardCellSnapshot(
            cell: BoardCell(column: 0, row: 0),
            state: .open,
            itemKind: .cookingPot,
            loadedCookingIngredientKinds: [.seasoningSauce, .noodle]
        )
        store.save(
            BoardProgressSnapshot(layoutVersion: 3, cells: [cellSnapshot])
        )

        let restored = try #require(store.load(expectedLayoutVersion: 3))
        #expect(
            restored.cells.first?.cookingIngredientKinds
                == [.seasoningSauce, .noodle]
        )
    }

    @Test
    func 돌을깬뒤남은상위아이템을새장면에서복원한다() throws {
        let suiteName = "BoardProgressStoreTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = BoardProgressStore(defaults: defaults)
        let layout = BoardExpansionLayout.prototype(columns: 7, rows: 9)
        let clearedCell = BoardCell(
            column: layout.initialGeneratorCell.column,
            row: layout.initialGeneratorCell.row - 1
        )

        var cells: [BoardCellSnapshot] = []
        for row in 0..<9 {
            for column in 0..<7 {
                let cell = BoardCell(column: column, row: row)
                var state = layout.initialState(at: cell)
                var itemKind: BoardItemKind?

                if cell == layout.initialGeneratorCell {
                    itemKind = .grainSack
                } else if state == .rockBlocked {
                    itemKind = layout.lockedItemKind(at: cell)
                }

                // 잠긴 밀과 일반 밀을 합친 뒤에는 해당 칸이 열리고 밀가루가 남습니다.
                if cell == clearedCell {
                    state = .open
                    itemKind = .flour
                }

                cells.append(
                    BoardCellSnapshot(
                        cell: cell,
                        state: state,
                        itemKind: itemKind,
                        loadedCookingIngredientKind: nil
                    )
                )
            }
        }

        store.save(
            BoardProgressSnapshot(
                layoutVersion: layout.version,
                cells: cells
            )
        )

        let scene = MergeBoardScene(size: CGSize(width: 390, height: 620))
        scene.boardProgressStore = store
        var restoredCounts: [BoardItemKind: Int] = [:]
        scene.onBoardItemCountsChanged = { restoredCounts = $0 }
        scene.didMove(to: SKView())

        #expect(restoredCounts[.grainSack] == 1)
        #expect(restoredCounts[.flour] == 1)
        #expect(restoredCounts[.wheat] == nil)
    }
}
