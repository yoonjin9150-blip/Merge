//
//  BoardExpansionLayout.swift
//  Merge
//
//  최초 개방 영역과 봉인 해제 시 나타날 아이템 배치를 정의합니다.
//

struct BoardExpansionLayout {
    static let currentVersion = 1

    let version: Int
    let initialOpenCells: Set<BoardCell>
    let initialGeneratorCell: BoardCell
    let lockedItemKindsByCell: [BoardCell: BoardItemKind]

    func initialState(at cell: BoardCell) -> BoardCellState {
        if initialOpenCells.contains(cell) {
            return .open
        }

        let touchesOpenCell = orthogonalNeighbors(of: cell).contains {
            initialOpenCells.contains($0)
        }
        return touchesOpenCell ? .rockBlocked : .sealed
    }

    func lockedItemKind(at cell: BoardCell) -> BoardItemKind? {
        lockedItemKindsByCell[cell]
    }

    // 7×9 보드에서 중앙의 3×4 영역만 먼저 사용합니다.
    // 최종 콘텐츠 배치 전까지는 중앙에서 떨어진 거리로 곡물 단계가 높아지는 고정 테스트 맵입니다.
    static func prototype(columns: Int, rows: Int) -> BoardExpansionLayout {
        precondition(columns >= 3 && rows >= 4, "확장 보드는 최소 3×4 이상이어야 합니다.")

        let openColumnStart = (columns - 3) / 2
        let openRowStart = (rows - 4) / 2
        let openColumns = openColumnStart..<(openColumnStart + 3)
        let openRows = openRowStart..<(openRowStart + 4)

        var initialOpenCells: Set<BoardCell> = []
        for row in openRows {
            for column in openColumns {
                initialOpenCells.insert(BoardCell(column: column, row: row))
            }
        }

        var lockedItemKindsByCell: [BoardCell: BoardItemKind] = [:]
        for row in 0..<rows {
            for column in 0..<columns {
                let cell = BoardCell(column: column, row: row)
                guard !initialOpenCells.contains(cell) else {
                    continue
                }

                let distance = initialOpenCells.map {
                    abs($0.column - column) + abs($0.row - row)
                }.min() ?? 1

                let kind: BoardItemKind
                switch distance {
                case 1:
                    kind = .wheat
                case 2:
                    kind = .flour
                case 3:
                    kind = .dough
                default:
                    kind = .noodle
                }

                lockedItemKindsByCell[cell] = kind
            }
        }

        return BoardExpansionLayout(
            version: currentVersion,
            initialOpenCells: initialOpenCells,
            initialGeneratorCell: BoardCell(column: openColumnStart, row: openRowStart),
            lockedItemKindsByCell: lockedItemKindsByCell
        )
    }

    private func orthogonalNeighbors(of cell: BoardCell) -> [BoardCell] {
        [
            BoardCell(column: cell.column, row: cell.row - 1),
            BoardCell(column: cell.column + 1, row: cell.row),
            BoardCell(column: cell.column, row: cell.row + 1),
            BoardCell(column: cell.column - 1, row: cell.row)
        ]
    }
}
