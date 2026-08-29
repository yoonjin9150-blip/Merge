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
    let loadedCookingIngredientKind: BoardItemKind?
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
