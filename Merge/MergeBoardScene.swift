//
//  MergeBoardScene.swift
//  Merge
//
//  7 × 9 머지 보드와 테스트 재료를 보여 주는 SpriteKit 장면입니다.
//

import SpriteKit

final class MergeBoardScene: SKScene {

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
    private var selectedItem: SKLabelNode?

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
        addIngredientEmoji("🌾", column: 0, row: 0)
        addIngredientEmoji("🌾", column: 1, row: 0)
    }

    private func addIngredientEmoji(_ emoji: String, column: Int, row: Int) {
        let item = SKLabelNode(text: emoji)

        item.fontSize = cellSize * 0.58
        item.verticalAlignmentMode = .center
        item.horizontalAlignmentMode = .center
        item.position = positionForCell(column: column, row: row)
        item.zPosition = 1
        item.name = "ingredient"

        boardNode.addChild(item)
    }

    // MARK: - Touch Drag

    // 손가락을 화면에 댄 순간입니다.
    // 터치 위치에 재료가 있으면, 그 재료를 이번 드래그의 대상으로 저장합니다.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: self)
        guard let item = atPoint(touchLocation) as? SKLabelNode,
              item.name == "ingredient" else {
            return
        }

        selectedItem = item
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
    // 아직은 스냅·머지 판정을 하지 않고, 드래그 대상만 해제합니다.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDragging()
    }

    // 전화 수신 등으로 터치가 취소되는 경우에도 드래그 상태를 정리합니다.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishDragging()
    }

    private func finishDragging() {
        selectedItem?.zPosition = 1
        selectedItem = nil
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
}
