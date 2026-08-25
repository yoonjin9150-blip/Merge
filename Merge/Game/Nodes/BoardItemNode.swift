//
//  BoardItemNode.swift
//  Merge
//
//  보드 아이템의 화면 표시와 선택 상태를 관리합니다.
//

import SpriteKit

final class BoardItemNode: SKNode {
    let kind: BoardItemKind
    var cell: BoardCell
    private var selectionIndicator: SKShapeNode?
    private var orderCheckIndicator: SKNode?

    // 생성기에서 목표 칸으로 이동하는 연출이 끝나기 전까지 true입니다.
    // BoardState에서는 이미 목표 칸을 점유하지만, 화면에서는 숨겨 두고 조작하지 않습니다.
    var isAwaitingSpawnArrival = false

    var isSelected = false {
        didSet {
            selectionIndicator?.isHidden = !isSelected
        }
    }

    // 현재 활성 주문의 완성품 또는 재료로 사용할 수 있는 아이템인지 표시합니다.
    // 체크 노드는 아이템의 자식이므로 드래그하거나 스냅해도 아이템과 함께 이동합니다.
    var showsOrderCheck = false {
        didSet {
            orderCheckIndicator?.isHidden = !showsOrderCheck
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

        let orderCheck = makeOrderCheckIndicator(cellSize: cellSize)
        addChild(orderCheck)
        orderCheckIndicator = orderCheck

        if kind.isGenerator {
            addChild(makeGeneratorEnergyIndicator(cellSize: cellSize))
            addChild(makeGeneratorSparkleContainer(cellSize: cellSize))
        }

        if kind.isMaximumMergeLevel {
            addChild(makeMaximumLevelIndicator(cellSize: cellSize))
        }
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
        // BoardItemNode 자체는 터치와 위치를 관리하는 컨테이너 역할만 합니다.
        // 실제 그림은 자식 노드로 두어 터치 영역과 픽셀 이미지 표시를 분리합니다.
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
        // 역할 배지나 주문 체크와 겹쳐도 선택 상태가 가장 위에서 보이게 합니다.
        indicator.zPosition = 3
        indicator.isHidden = true
        indicator.name = "selectionIndicator"
        return indicator
    }

    private func makeOrderCheckIndicator(cellSize: CGFloat) -> SKNode {
        let container = SKNode()
        let badgeSide = cellSize * 0.28
        let badgePosition = cellSize * 0.29

        let background = SKShapeNode(
            rectOf: CGSize(width: badgeSide, height: badgeSide),
            cornerRadius: cellSize * 0.04
        )
        background.fillColor = SKColor(
            red: 0.20,
            green: 0.72,
            blue: 0.36,
            alpha: 1
        )
        background.strokeColor = .white
        background.lineWidth = max(1.5, cellSize * 0.035)

        let checkPath = CGMutablePath()
        checkPath.move(
            to: CGPoint(x: -badgeSide * 0.25, y: 0)
        )
        checkPath.addLine(
            to: CGPoint(x: -badgeSide * 0.06, y: -badgeSide * 0.20)
        )
        checkPath.addLine(
            to: CGPoint(x: badgeSide * 0.28, y: badgeSide * 0.22)
        )

        let check = SKShapeNode(path: checkPath)
        check.strokeColor = .white
        check.lineWidth = max(2, cellSize * 0.065)
        check.lineCap = .square
        check.lineJoin = .miter

        container.addChild(background)
        container.addChild(check)
        container.position = CGPoint(
            x: badgePosition,
            y: -badgePosition
        )
        container.zPosition = 2
        container.isHidden = true
        container.name = "orderCheckIndicator"
        return container
    }

    private func makeGeneratorEnergyIndicator(cellSize: CGFloat) -> SKNode {
        let container = SKNode()
        let badgeSide = cellSize * 0.29

        let background = SKShapeNode(
            rectOf: CGSize(width: badgeSide, height: badgeSide),
            cornerRadius: cellSize * 0.045
        )
        background.fillColor = SKColor(
            red: 0.08,
            green: 0.07,
            blue: 0.20,
            alpha: 1
        )
        background.strokeColor = .white
        background.lineWidth = max(1.5, cellSize * 0.03)

        // 픽셀 에셋을 추가하지 않고도 선명하게 보이도록 번개 실루엣을 좌표로 그립니다.
        let boltWidth = badgeSide * 0.52
        let boltHeight = badgeSide * 0.72
        let boltPath = CGMutablePath()
        boltPath.move(
            to: CGPoint(x: boltWidth * 0.08, y: boltHeight * 0.50)
        )
        boltPath.addLine(
            to: CGPoint(x: -boltWidth * 0.50, y: -boltHeight * 0.04)
        )
        boltPath.addLine(
            to: CGPoint(x: -boltWidth * 0.10, y: -boltHeight * 0.04)
        )
        boltPath.addLine(
            to: CGPoint(x: -boltWidth * 0.24, y: -boltHeight * 0.50)
        )
        boltPath.addLine(
            to: CGPoint(x: boltWidth * 0.50, y: boltHeight * 0.08)
        )
        boltPath.addLine(
            to: CGPoint(x: boltWidth * 0.10, y: boltHeight * 0.08)
        )
        boltPath.closeSubpath()

        let bolt = SKShapeNode(path: boltPath)
        bolt.fillColor = SKColor(
            red: 1,
            green: 0.78,
            blue: 0.10,
            alpha: 1
        )
        bolt.strokeColor = SKColor(
            red: 1,
            green: 0.94,
            blue: 0.42,
            alpha: 1
        )
        bolt.lineWidth = max(1, cellSize * 0.018)

        container.addChild(background)
        container.addChild(bolt)
        container.position = CGPoint(
            x: cellSize * 0.29,
            y: -cellSize * 0.29
        )
        container.zPosition = 2
        container.name = "generatorEnergyIndicator"
        return container
    }

    private func makeMaximumLevelIndicator(cellSize: CGFloat) -> SKNode {
        let crownWidth = cellSize * 0.32
        let crownHeight = cellSize * 0.23
        let crownPath = CGMutablePath()

        crownPath.move(
            to: CGPoint(x: -crownWidth * 0.50, y: -crownHeight * 0.50)
        )
        crownPath.addLine(
            to: CGPoint(x: -crownWidth * 0.50, y: crownHeight * 0.12)
        )
        crownPath.addLine(
            to: CGPoint(x: -crownWidth * 0.38, y: crownHeight * 0.48)
        )
        crownPath.addLine(
            to: CGPoint(x: -crownWidth * 0.12, y: crownHeight * 0.14)
        )
        crownPath.addLine(
            to: CGPoint(x: 0, y: crownHeight * 0.50)
        )
        crownPath.addLine(
            to: CGPoint(x: crownWidth * 0.12, y: crownHeight * 0.14)
        )
        crownPath.addLine(
            to: CGPoint(x: crownWidth * 0.38, y: crownHeight * 0.48)
        )
        crownPath.addLine(
            to: CGPoint(x: crownWidth * 0.50, y: crownHeight * 0.12)
        )
        crownPath.addLine(
            to: CGPoint(x: crownWidth * 0.50, y: -crownHeight * 0.50)
        )
        crownPath.closeSubpath()

        let crown = SKShapeNode(path: crownPath)
        crown.fillColor = SKColor(
            red: 1,
            green: 0.78,
            blue: 0.10,
            alpha: 1
        )
        crown.strokeColor = SKColor(
            red: 0.08,
            green: 0.07,
            blue: 0.20,
            alpha: 1
        )
        crown.lineWidth = max(1.5, cellSize * 0.03)
        crown.position = CGPoint(
            x: -cellSize * 0.28,
            y: -cellSize * 0.30
        )
        crown.zPosition = 2
        crown.name = "maximumLevelIndicator"
        return crown
    }

    private func makeGeneratorSparkleContainer(cellSize: CGFloat) -> SKNode {
        let container = SKNode()
        container.zPosition = 1
        container.name = "generatorSparkleContainer"

        let sparkleDefinitions: [(CGPoint, CGFloat, TimeInterval)] = [
            (
                CGPoint(x: -cellSize * 0.27, y: cellSize * 0.27),
                cellSize * 0.08,
                0
            ),
            (
                CGPoint(x: cellSize * 0.28, y: cellSize * 0.18),
                cellSize * 0.07,
                0.35
            ),
            (
                CGPoint(x: cellSize * 0.10, y: cellSize * 0.32),
                cellSize * 0.06,
                0.70
            )
        ]

        for (position, pixelSize, delay) in sparkleDefinitions {
            let sparkle = makePixelSparkle(pixelSize: pixelSize)
            sparkle.position = position
            sparkle.alpha = 0.28
            sparkle.setScale(0.72)
            container.addChild(sparkle)

            let appear = SKAction.group([
                .fadeAlpha(to: 1, duration: 0.20),
                .scale(to: 1.08, duration: 0.20)
            ])
            appear.timingMode = .easeOut

            let disappear = SKAction.group([
                .fadeAlpha(to: 0.28, duration: 0.32),
                .scale(to: 0.72, duration: 0.32)
            ])
            disappear.timingMode = .easeIn

            // 서로 다른 지연 시간을 주어 세 반짝임이 동시에 깜박이지 않게 합니다.
            // 짧게 빛난 뒤 쉬는 시간을 두어 생성기 이미지가 과하게 번쩍이지 않게 합니다.
            sparkle.run(
                .repeatForever(
                    .sequence([
                        .wait(forDuration: delay),
                        appear,
                        .wait(forDuration: 0.18),
                        disappear,
                        .wait(forDuration: 0.72)
                    ])
                )
            )
        }

        return container
    }

    private func makePixelSparkle(pixelSize: CGFloat) -> SKNode {
        let sparkle = SKNode()
        let sparkleColor = SKColor(
            red: 0.12,
            green: 0.78,
            blue: 0.88,
            alpha: 1
        )
        let shadowColor = SKColor(
            red: 0.08,
            green: 0.07,
            blue: 0.20,
            alpha: 0.80
        )

        let horizontalShadow = SKSpriteNode(
            color: shadowColor,
            size: CGSize(width: pixelSize * 3, height: pixelSize)
        )
        let verticalShadow = SKSpriteNode(
            color: shadowColor,
            size: CGSize(width: pixelSize, height: pixelSize * 3)
        )
        horizontalShadow.position = CGPoint(x: 1, y: -1)
        verticalShadow.position = CGPoint(x: 1, y: -1)

        let horizontalPixel = SKSpriteNode(
            color: sparkleColor,
            size: CGSize(width: pixelSize * 3, height: pixelSize)
        )
        let verticalPixel = SKSpriteNode(
            color: sparkleColor,
            size: CGSize(width: pixelSize, height: pixelSize * 3)
        )

        sparkle.addChild(horizontalShadow)
        sparkle.addChild(verticalShadow)
        sparkle.addChild(horizontalPixel)
        sparkle.addChild(verticalPixel)
        return sparkle
    }
}
