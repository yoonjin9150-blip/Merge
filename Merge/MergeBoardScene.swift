//
//  MergeBoardScene.swift
//  Merge
//
//  7 × 9 머지 보드와 테스트 재료를 보여 주는 SpriteKit 장면입니다.
//

import SpriteKit

final class MergeBoardScene: SKScene {

    // 재료를 문자열이 아닌 타입으로 구분해 오타로 인한 판정 오류를 막습니다.
    // 이번 기술 검증에서는 밀과 밀가루 한 단계만 정의합니다.
    private enum IngredientKind {
        case wheat
        case flour

        var emoji: String {
            switch self {
            case .wheat:
                return "🌾"
            case .flour:
                return "🥣"
            }
        }

        // 같은 재료 두 개를 머지했을 때 만들어질 다음 단계입니다.
        // 밀가루 이후 단계는 전체 머지 트리를 구현할 때 추가합니다.
        var nextKind: IngredientKind? {
            switch self {
            case .wheat:
                return .flour
            case .flour:
                return nil
            }
        }
    }

    // 보드 안 한 칸의 주소입니다.
    // 화면 위치(CGPoint)와 게임 규칙에서 사용하는 행·열을 구분하기 위해 별도 타입으로 둡니다.
    private struct BoardCell: Hashable {
        let column: Int
        let row: Int
    }

    // 화면에 보이는 이모지와 게임 규칙에 필요한 정보를 함께 보관하는 아이템 노드입니다.
    private final class IngredientNode: SKLabelNode {
        let kind: IngredientKind
        var cell: BoardCell

        init(
            kind: IngredientKind,
            cell: BoardCell
        ) {
            self.kind = kind
            self.cell = cell
            super.init()
            text = kind.emoji
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    // MARK: - 보드 규칙

    // 가로 칸 수입니다. Hollywood Merge와 같이 7칸으로 설정했습니다.
    private let columns = 7

    // 세로 칸 수입니다. Hollywood Merge와 같이 9칸으로 설정했습니다.
    private let rows = 9

    // 보드의 칸과 아이템을 담는 부모 노드입니다.
    private let boardNode = SKNode()

    // 화면 크기에 맞춰 계산되는 실제 한 칸의 크기입니다.
    private var cellSize: CGFloat = 0

    // 보드의 왼쪽 아래 시작점입니다.
    private var boardOrigin = CGPoint.zero

    // 현재 손가락으로 잡고 있는 아이템입니다.
    // touchesBegan에서 저장하고, touchesMoved에서 이 아이템만 움직입니다.
    private var selectedItem: IngredientNode?

    // 드래그를 시작한 칸입니다.
    // 손가락을 뗐을 때 빈 칸 이동·자리 교체·원래 칸 복귀를 판단하는 기준이 됩니다.
    private var originalCell: BoardCell?

    // 각 행·열에 어떤 아이템이 있는지 관리하는 실제 보드 상태입니다.
    // 아이템 노드의 화면 위치만 보고 빈 칸을 판단하지 않고, 이 딕셔너리를 기준으로 판단합니다.
    private var itemsByCell: [BoardCell: IngredientNode] = [:]

    // 아이템을 잡은 지점과 아이템 중심 사이의 거리입니다.
    // 손가락을 아이템의 가장자리에서 눌러도 아이템이 갑자기 점프하지 않게 합니다.
    private var dragOffset = CGPoint.zero

    // MARK: - Scene Life Cycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(boardNode)
        buildBoard()
    }

    // MARK: - Board Drawing

    private func buildBoard() {
        // 보드와 테스트 아이템을 처음 그립니다.
        boardNode.removeAllChildren()
        itemsByCell.removeAll()
        selectedItem = nil
        originalCell = nil

        // 보드의 바깥 여백입니다. 이 숫자를 바꾸면 보드와 화면 가장자리 사이가 바뀝니다.
        let horizontalPadding: CGFloat = 18
        let verticalPadding: CGFloat = 14

        let availableWidth = size.width - (horizontalPadding * 2)
        let availableHeight = size.height - (verticalPadding * 2)

        // 7 × 9 보드가 SpriteKit 영역 안에 모두 들어가도록 칸 크기를 계산합니다.
        cellSize = min(
            availableWidth / CGFloat(columns),
            availableHeight / CGFloat(rows)
        )

        let boardWidth = cellSize * CGFloat(columns)
        let boardHeight = cellSize * CGFloat(rows)

        // 보드 전체가 SpriteKit 영역의 중앙에 오도록 시작점을 계산합니다.
        boardOrigin = CGPoint(
            x: (size.width - boardWidth) / 2,
            y: (size.height - boardHeight) / 2
        )

        drawCells()
        addTestItems()
    }

    private func drawCells() {
        for row in 0..<rows {
            for column in 0..<columns {
                let cell = SKShapeNode(
                    rectOf: CGSize(width: cellSize - 3, height: cellSize - 3),
                    cornerRadius: 7
                )

                cell.position = positionForCell(column: column, row: row)
                cell.fillColor = SKColor(
                    red: 0.95,
                    green: 0.88,
                    blue: 0.74,
                    alpha: 1
                )
                cell.strokeColor = SKColor(
                    red: 0.78,
                    green: 0.65,
                    blue: 0.47,
                    alpha: 1
                )
                cell.lineWidth = 1
                cell.zPosition = 0

                boardNode.addChild(cell)
            }
        }
    }

    // MARK: - Test Items

    private func addTestItems() {
        // row 0은 화면에서 가장 위쪽인 1행입니다.
        // column 0은 왼쪽 첫 번째 칸입니다.
        // 아이템 위치를 바꾸고 싶다면 아래 column·row 숫자를 바꾸면 됩니다.
        addIngredient(
            .wheat,
            column: 0,
            row: 0
        )
        addIngredient(
            .wheat,
            column: 1,
            row: 0
        )
    }

    @discardableResult
    private func addIngredient(
        _ kind: IngredientKind,
        column: Int,
        row: Int
    ) -> IngredientNode {
        let cell = BoardCell(column: column, row: row)
        let item = IngredientNode(
            kind: kind,
            cell: cell
        )

        item.fontSize = cellSize * 0.58
        item.verticalAlignmentMode = .center
        item.horizontalAlignmentMode = .center
        item.position = positionForCell(cell)
        item.zPosition = 1
        item.name = "ingredient"

        boardNode.addChild(item)
        itemsByCell[cell] = item
        return item
    }

    // MARK: - Touch Drag

    // 손가락을 화면에 댄 순간입니다.
    // 터치 위치에 재료가 있으면, 그 재료를 이번 드래그의 대상으로 저장합니다.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: self)
        guard let item = atPoint(touchLocation) as? IngredientNode,
              item.name == "ingredient" else {
            return
        }

        selectedItem = item
        originalCell = item.cell
        dragOffset = CGPoint(
            x: item.position.x - touchLocation.x,
            y: item.position.y - touchLocation.y
        )

        // 드래그 중인 재료가 다른 칸보다 앞에 보이도록 합니다.
        item.zPosition = 2
    }

    // 손가락을 누른 채 움직이는 동안 계속 호출됩니다.
    // 선택된 재료를 손가락 위치로 옮기되, 재료 전체가 보드 안에 남도록 제한합니다.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let item = selectedItem else { return }

        let touchLocation = touch.location(in: self)
        let proposedPosition = CGPoint(
            x: touchLocation.x + dragOffset.x,
            y: touchLocation.y + dragOffset.y
        )

        item.position = constrainedPosition(for: item, proposedPosition: proposedPosition)
    }

    // 손가락을 뗀 순간입니다.
    // 현재 아이템 중심에서 가장 가까운 칸을 찾고, 그 칸의 점유 상태에 따라 스냅합니다.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let item = selectedItem, let startCell = originalCell else {
            finishDragging()
            return
        }

        let targetCell = nearestCell(to: item.position)
        resolveDrop(of: item, from: startCell, to: targetCell)
        finishDragging()
    }

    // 전화 수신 등으로 터치가 취소되면 보드 상태를 바꾸지 않고 원래 칸으로 돌려놓습니다.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let item = selectedItem, let startCell = originalCell {
            item.position = positionForCell(startCell)
        }

        finishDragging()
    }

    // MARK: - Grid Snap

    private func resolveDrop(
        of draggedItem: IngredientNode,
        from startCell: BoardCell,
        to targetCell: BoardCell
    ) {
        // 시작한 칸에 다시 놓았다면 데이터는 바꾸지 않고 칸 중앙에 정확히 맞춥니다.
        guard targetCell != startCell else {
            draggedItem.position = positionForCell(startCell)
            return
        }

        // 목표 칸이 비었다면 시작 칸을 비우고 목표 칸에 아이템을 등록합니다.
        // 화면 위치와 보드 상태를 같은 시점에 갱신해야 둘이 어긋나지 않습니다.
        guard let targetItem = itemsByCell[targetCell] else {
            itemsByCell[startCell] = nil
            itemsByCell[targetCell] = draggedItem
            draggedItem.cell = targetCell
            draggedItem.position = positionForCell(targetCell)
            return
        }

        let canMergeLater = draggedItem.kind == targetItem.kind

        // 같은 종류·같은 레벨은 나중에 머지될 대상입니다.
        // 이번 작업에서는 머지를 제외했으므로 두 아이템과 보드 상태를 그대로 두고 복귀시킵니다.
        guard !canMergeLater else {
            draggedItem.position = positionForCell(startCell)
            return
        }

        // 다른 종류 또는 다른 레벨 아이템이 있다면 두 칸의 점유 상태를 교체합니다.
        // 그 뒤 두 노드도 교체된 칸 중앙에 배치해 화면과 데이터가 같은 결과를 가리키게 합니다.
        itemsByCell[startCell] = targetItem
        itemsByCell[targetCell] = draggedItem

        targetItem.cell = startCell
        draggedItem.cell = targetCell
        targetItem.position = positionForCell(startCell)
        draggedItem.position = positionForCell(targetCell)
    }

    private func nearestCell(to position: CGPoint) -> BoardCell {
        // 보드 시작점에서 몇 칸 떨어졌는지 계산한 뒤 반올림해 가장 가까운 열을 찾습니다.
        let rawColumn = ((position.x - boardOrigin.x) / cellSize) - 0.5
        let columnFromLeft = Int(rawColumn.rounded())

        // SpriteKit의 y축은 아래에서 위로 증가하므로 먼저 아래 기준 행을 구합니다.
        let rawRowFromBottom = ((position.y - boardOrigin.y) / cellSize) - 0.5
        let rowFromBottom = Int(rawRowFromBottom.rounded())

        let clampedColumn = min(max(columnFromLeft, 0), columns - 1)
        let clampedRowFromBottom = min(max(rowFromBottom, 0), rows - 1)

        // 게임에서는 화면 맨 위를 row 0으로 사용하므로 행 번호를 뒤집습니다.
        return BoardCell(
            column: clampedColumn,
            row: rows - 1 - clampedRowFromBottom
        )
    }

    private func finishDragging() {
        selectedItem?.zPosition = 1
        selectedItem = nil
        originalCell = nil
        dragOffset = .zero
    }

    private func constrainedPosition(
        for item: SKLabelNode,
        proposedPosition: CGPoint
    ) -> CGPoint {
        let boardBounds = CGRect(
            x: boardOrigin.x,
            y: boardOrigin.y,
            width: cellSize * CGFloat(columns),
            height: cellSize * CGFloat(rows)
        )

        // SKLabelNode의 실제 크기를 사용해, 이모지가 반쯤 잘려 나가지 않게 제한합니다.
        let itemFrame = item.frame
        let leftInset = item.position.x - itemFrame.minX
        let rightInset = itemFrame.maxX - item.position.x
        let bottomInset = item.position.y - itemFrame.minY
        let topInset = itemFrame.maxY - item.position.y

        return CGPoint(
            x: min(max(proposedPosition.x, boardBounds.minX + leftInset), boardBounds.maxX - rightInset),
            y: min(max(proposedPosition.y, boardBounds.minY + bottomInset), boardBounds.maxY - topInset)
        )
    }

    // MARK: - Cell Position

    private func positionForCell(column: Int, row: Int) -> CGPoint {
        let x = boardOrigin.x + (CGFloat(column) + 0.5) * cellSize

        // SpriteKit은 화면 아래가 y = 0입니다.
        // 그래서 row 0이 화면의 맨 위 1행이 되도록 행 번호를 뒤집어 계산합니다.
        let y = boardOrigin.y
            + (CGFloat(rows - row) - 0.5) * cellSize

        return CGPoint(x: x, y: y)
    }

    private func positionForCell(_ cell: BoardCell) -> CGPoint {
        positionForCell(column: cell.column, row: cell.row)
    }
}
