//
//  BoardProgressStore.swift
//  Merge
//
//  보드의 칸 해제 상태와 아이템 위치를 앱 재실행 뒤에도 복원합니다.
//

import Foundation

struct BoardCellSnapshot: Codable, Equatable {
    let cell: BoardCell
    let state: BoardCellState
    let itemKind: BoardItemKind?
    // 이전 버전의 냄비 한 칸 저장값을 계속 읽기 위한 호환 필드입니다.
    let loadedCookingIngredientKind: BoardItemKind?
    // 두 재료 레시피도 투입 순서까지 그대로 복원하기 위한 현재 저장값입니다.
    let loadedCookingIngredientKinds: [BoardItemKind]?

    var cookingIngredientKinds: [BoardItemKind] {
        if let loadedCookingIngredientKinds {
            return loadedCookingIngredientKinds
        }

        return loadedCookingIngredientKind.map { [$0] } ?? []
    }

    init(
        cell: BoardCell,
        state: BoardCellState,
        itemKind: BoardItemKind?,
        loadedCookingIngredientKind: BoardItemKind?
    ) {
        self.cell = cell
        self.state = state
        self.itemKind = itemKind
        self.loadedCookingIngredientKind = loadedCookingIngredientKind
        loadedCookingIngredientKinds = loadedCookingIngredientKind.map { [$0] } ?? []
    }

    init(
        cell: BoardCell,
        state: BoardCellState,
        itemKind: BoardItemKind?,
        loadedCookingIngredientKinds: [BoardItemKind]
    ) {
        self.cell = cell
        self.state = state
        self.itemKind = itemKind
        loadedCookingIngredientKind = loadedCookingIngredientKinds.first
        self.loadedCookingIngredientKinds = loadedCookingIngredientKinds
    }
}

struct BoardProgressSnapshot: Codable, Equatable {
    let layoutVersion: Int
    let cells: [BoardCellSnapshot]
}

final class BoardProgressStore {
    private enum StorageKey {
        static let boardProgress = "merge.board.progress"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load(expectedLayoutVersion: Int) -> BoardProgressSnapshot? {
        guard let data = defaults.data(forKey: StorageKey.boardProgress),
              let snapshot = try? decoder.decode(BoardProgressSnapshot.self, from: data),
              snapshot.layoutVersion == expectedLayoutVersion else {
            return nil
        }

        return snapshot
    }

    func save(_ snapshot: BoardProgressSnapshot) {
        guard let data = try? encoder.encode(snapshot) else {
            assertionFailure("보드 진행 상태를 인코딩하지 못했습니다.")
            return
        }

        defaults.set(data, forKey: StorageKey.boardProgress)
    }

    func clear() {
        defaults.removeObject(forKey: StorageKey.boardProgress)
    }
}
