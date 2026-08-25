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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureAppearance(cellSize: CGFloat) {
        configureItemVisual(cellSize: cellSize)
        name = "boardItem"

        let indicator = makeSelectionIndicator(cellSize: cellSize)
        addChild(indicator)
        selectionIndicator = indicator
    }

    // 보드의 실제 아이템과 생성기에서 날아가는 연출이 같은 모습으로 보이게 만드는 공통 함수입니다.
    static func makeVisualNode(
        for kind: BoardItemKind,
        cellSize: CGFloat
    ) -> SKNode {
        let texture = SKTexture(imageNamed: kind.textureName)

        // 픽셀 이미지가 확대·축소될 때 경계가 흐려지지 않도록 가장 가까운 픽셀을 사용합니다.
        texture.filteringMode = .nearest

        let sprite = SKSpriteNode(texture: texture)
        let sideLength = cellSize * CGFloat(kind.visualScale)
        sprite.size = CGSize(width: sideLength, height: sideLength)
        sprite.name = "itemVisual"
        return sprite
    }

    private func configureItemVisual(cellSize: CGFloat) {
        // SKLabelNode 자체는 터치와 위치를 관리하는 컨테이너 역할만 합니다.
        // 실제 그림은 자식 노드로 두어 터치 영역과 픽셀 이미지 표시를 분리합니다.
        text = nil
        verticalAlignmentMode = .center
        horizontalAlignmentMode = .center

        let visualNode = Self.makeVisualNode(for: kind, cellSize: cellSize)
        addChild(visualNode)
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
