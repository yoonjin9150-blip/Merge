//
//  BoardItemNode.swift
//  Merge
//
//  보드 아이템의 화면 표시와 선택 상태를 관리합니다.
//

import SpriteKit

final class BoardItemNode: SKLabelNode {
    let kind: BoardItemKind
    var cell: BoardCell
    private var selectionIndicator: SKShapeNode?

    // 생성기에서 목표 칸으로 이동하는 연출이 끝나기 전까지 true입니다.
    // BoardState에서는 이미 목표 칸을 점유하지만, 화면에서는 숨겨 두고 조작하지 않습니다.
    var isAwaitingSpawnArrival = false

    var isSelected = false {
        didSet {
            selectionIndicator?.isHidden = !isSelected
        }
    }

    init(
        kind: BoardItemKind,
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

    func configureAppearance(cellSize: CGFloat) {
        fontSize = cellSize * 0.58
        verticalAlignmentMode = .center
        horizontalAlignmentMode = .center
        name = "boardItem"

        let indicator = makeSelectionIndicator(cellSize: cellSize)
        addChild(indicator)
        selectionIndicator = indicator
    }

    private func makeSelectionIndicator(cellSize: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()

        // 아이템 중심에서 선택 표시 꼭짓점까지의 거리입니다.
        let halfSize = cellSize * 0.36

        // 각 꼭짓점에서 가로·세로로 뻗는 선의 길이입니다.
        let cornerLength = cellSize * 0.14

        // 왼쪽 위 ┌
        path.move(to: CGPoint(x: -halfSize + cornerLength, y: halfSize))
        path.addLine(to: CGPoint(x: -halfSize, y: halfSize))
        path.addLine(to: CGPoint(x: -halfSize, y: halfSize - cornerLength))

        // 오른쪽 위 ┐
        path.move(to: CGPoint(x: halfSize - cornerLength, y: halfSize))
        path.addLine(to: CGPoint(x: halfSize, y: halfSize))
        path.addLine(to: CGPoint(x: halfSize, y: halfSize - cornerLength))

        // 왼쪽 아래 └
        path.move(to: CGPoint(x: -halfSize, y: -halfSize + cornerLength))
        path.addLine(to: CGPoint(x: -halfSize, y: -halfSize))
        path.addLine(to: CGPoint(x: -halfSize + cornerLength, y: -halfSize))

        // 오른쪽 아래 ┘
        path.move(to: CGPoint(x: halfSize, y: -halfSize + cornerLength))
        path.addLine(to: CGPoint(x: halfSize, y: -halfSize))
        path.addLine(to: CGPoint(x: halfSize - cornerLength, y: -halfSize))

        let indicator = SKShapeNode(path: path)
        indicator.strokeColor = SKColor(
            red: 0.12,
            green: 0.78,
            blue: 0.88,
            alpha: 1
        )
        indicator.fillColor = .clear
        indicator.lineWidth = 4
        indicator.lineCap = .round
        indicator.lineJoin = .round
        indicator.zPosition = 1
        indicator.isHidden = true
        indicator.name = "selectionIndicator"
        return indicator
    }
}
