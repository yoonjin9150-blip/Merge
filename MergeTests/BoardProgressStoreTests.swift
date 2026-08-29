//
//  BoardProgressStoreTests.swift
//  MergeTests
//
//  칸 해제 상태와 아이템 위치의 저장·복원을 검증합니다.
//

import Foundation
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
}
