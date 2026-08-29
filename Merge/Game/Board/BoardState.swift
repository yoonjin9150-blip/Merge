//
//  BoardState.swift
//  Merge
//
//  보드의 칸별 점유 상태와 아이템 이동 규칙을 관리합니다.
//

final class BoardState {
    let columns: Int
    let rows: Int

    // 화면 노드의 위치가 아니라 이 딕셔너리를 기준으로 빈 칸과 점유 칸을 판단합니다.
    private(set) var itemsByCell: [BoardCell: BoardItemNode] = [:]

    var itemCount: Int {
        itemsByCell.count
    }

    init(columns: Int, rows: Int) {
        precondition(columns > 0 && rows > 0, "보드의 행과 열은 1 이상이어야 합니다.")
        self.columns = columns
        self.rows = rows
    }

    func reset() {
        itemsByCell.removeAll()
    }

    func item(at cell: BoardCell) -> BoardItemNode? {
        itemsByCell[cell]
    }

    // 같은 종류가 여러 개라면 화면 위쪽 행부터, 같은 행에서는 왼쪽 열부터 반환합니다.
    // 주문 납품이 언제나 같은 기준으로 아이템을 선택하도록 딕셔너리 순서에 의존하지 않습니다.
    func items(of kind: BoardItemKind) -> [BoardItemNode] {
        itemsByCell
            .filter { _, item in item.kind == kind }
            .sorted { first, second in
                if first.key.row == second.key.row {
                    return first.key.column < second.key.column
                }

                return first.key.row < second.key.row
            }
            .map(\.value)
    }

    // 잠긴 아이템은 보드의 한 칸을 차지하지만 주문 납품이나 조리에는 사용할 수 없습니다.
    // 실제로 소비할 수 있는 아이템이 필요할 때는 이 함수를 사용합니다.
    func unlockedItems(of kind: BoardItemKind) -> [BoardItemNode] {
        items(of: kind).filter { !$0.isLocked }
    }

    func add(_ item: BoardItemNode, at cell: BoardCell) {
        precondition(contains(cell), "보드 범위를 벗어난 칸에는 아이템을 추가할 수 없습니다.")
        precondition(itemsByCell[cell] == nil, "이미 아이템이 있는 칸에는 새 아이템을 추가할 수 없습니다.")

        item.cell = cell
        itemsByCell[cell] = item
    }

    @discardableResult
    func removeItem(at cell: BoardCell) -> BoardItemNode? {
        itemsByCell.removeValue(forKey: cell)
    }

    func move(_ item: BoardItemNode, from startCell: BoardCell, to targetCell: BoardCell) {
        precondition(itemsByCell[startCell] === item, "이동할 아이템이 시작 칸의 상태와 일치하지 않습니다.")
        precondition(contains(targetCell), "보드 범위를 벗어난 칸으로 이동할 수 없습니다.")
        precondition(itemsByCell[targetCell] == nil, "아이템이 있는 칸에는 빈 칸 이동을 실행할 수 없습니다.")

        itemsByCell[startCell] = nil
        itemsByCell[targetCell] = item
        item.cell = targetCell
    }

    func swap(
        _ firstItem: BoardItemNode,
        at firstCell: BoardCell,
        with secondItem: BoardItemNode,
        at secondCell: BoardCell
    ) {
        precondition(itemsByCell[firstCell] === firstItem, "첫 번째 아이템과 칸의 상태가 일치하지 않습니다.")
        precondition(itemsByCell[secondCell] === secondItem, "두 번째 아이템과 칸의 상태가 일치하지 않습니다.")

        itemsByCell[firstCell] = secondItem
        itemsByCell[secondCell] = firstItem
        firstItem.cell = secondCell
        secondItem.cell = firstCell
    }

    func firstEmptyCell() -> BoardCell? {
        // row 0의 왼쪽부터 오른쪽으로 확인한 뒤 다음 행으로 내려갑니다.
        for row in 0..<rows {
            for column in 0..<columns {
                let cell = BoardCell(column: column, row: row)

                if itemsByCell[cell] == nil {
                    return cell
                }
            }
        }

        return nil
    }

    func contains(_ cell: BoardCell) -> Bool {
        (0..<columns).contains(cell.column) && (0..<rows).contains(cell.row)
    }
}
