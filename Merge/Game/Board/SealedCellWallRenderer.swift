//
//  SealedCellWallRenderer.swift
//  Merge
//
//  봉인된 칸을 하나로 이어진 황토 벽돌벽처럼 그립니다.
//

import SpriteKit

final class SealedCellWallRenderer {
    private enum NodeName {
        static let mortar = "sealedWallMortar"
        static let brick = "sealedWallBrick"
        static let crack = "sealedWallCrack"
    }

    private enum BreakAnimation {
        static let shakeStepDuration: TimeInterval = 0.025
        static let fragmentDuration: TimeInterval = 0.24
        static let totalDuration: TimeInterval = 0.36
    }

    private let mortarColor = SKColor(red: 0.24, green: 0.17, blue: 0.19, alpha: 1)
    private let brickColors = [
        SKColor(red: 0.56, green: 0.35, blue: 0.27, alpha: 1),
        SKColor(red: 0.63, green: 0.40, blue: 0.29, alpha: 1),
        SKColor(red: 0.50, green: 0.30, blue: 0.25, alpha: 1)
    ]
    private let brickHighlightColor = SKColor(red: 0.76, green: 0.52, blue: 0.36, alpha: 0.72)
    private let brickShadowColor = SKColor(red: 0.34, green: 0.20, blue: 0.20, alpha: 0.74)

    func makeCover(for cell: BoardCell, cellSize: CGFloat) -> SKNode {
        let cover = SKNode()
        cover.name = "sealedCellCover"

        // 격자선까지 덮어 인접한 봉인 칸이 각각의 상자가 아니라 한 장의 벽처럼 이어지게 합니다.
        let mortarBackground = SKSpriteNode(
            color: mortarColor,
            size: CGSize(width: cellSize + 2, height: cellSize + 2)
        )
        mortarBackground.name = NodeName.mortar
        mortarBackground.zPosition = -0.2
        cover.addChild(mortarBackground)

        let mortarWidth: CGFloat = 2
        let courseCount = 4
        let courseHeight = cellSize / CGFloat(courseCount)

        for course in 0..<courseCount {
            let globalCourse = (cell.row * courseCount) + course
            let isOffsetCourse = globalCourse.isMultiple(of: 2)
            let brickHeight = courseHeight - mortarWidth
            let y = (-cellSize / 2)
                + (CGFloat(course) * courseHeight)
                + (courseHeight / 2)

            if isOffsetCourse {
                // 이 줄의 벽돌은 칸 경계에서 잘린 반쪽 두 개입니다.
                // 바깥쪽 여백을 없애 옆 칸의 반쪽과 붙이고, 이음새는 칸 중앙에만 남깁니다.
                let halfWidth = (cellSize - mortarWidth) / 2
                let halfCenterOffset = (cellSize + mortarWidth) / 4
                addBrick(
                    to: cover,
                    cell: cell,
                    course: course,
                    index: 0,
                    size: CGSize(width: halfWidth, height: brickHeight),
                    position: CGPoint(x: -halfCenterOffset, y: y)
                )
                addBrick(
                    to: cover,
                    cell: cell,
                    course: course,
                    index: 1,
                    size: CGSize(width: halfWidth, height: brickHeight),
                    position: CGPoint(x: halfCenterOffset, y: y)
                )
            } else {
                addBrick(
                    to: cover,
                    cell: cell,
                    course: course,
                    index: 0,
                    size: CGSize(width: cellSize - mortarWidth, height: brickHeight),
                    position: CGPoint(x: 0, y: y)
                )
            }
        }

        addDeterministicCrack(to: cover, cell: cell, cellSize: cellSize)
        return cover
    }

    func animateBreaking(
        _ cover: SKNode,
        cellSize: CGFloat,
        completion: @escaping () -> Void
    ) {
        // 먼저 벽 전체가 짧게 흔들린 뒤 벽돌마다 서로 다른 방향으로 떨어집니다.
        let shake = SKAction.sequence([
            .moveBy(x: -2, y: 0, duration: BreakAnimation.shakeStepDuration),
            .moveBy(x: 4, y: 0, duration: BreakAnimation.shakeStepDuration),
            .moveBy(x: -2, y: 0, duration: BreakAnimation.shakeStepDuration)
        ])
        cover.run(shake)

        cover.childNode(withName: NodeName.mortar)?.run(.sequence([
            .wait(forDuration: BreakAnimation.shakeStepDuration * 2),
            .fadeOut(withDuration: 0.10)
        ]))

        let bricks = cover.children.filter { $0.name == NodeName.brick }
        for (index, brick) in bricks.enumerated() {
            let horizontalDirection: CGFloat
            if abs(brick.position.x) > 1 {
                horizontalDirection = brick.position.x < 0 ? -1 : 1
            } else {
                horizontalDirection = index.isMultiple(of: 2) ? -1 : 1
            }

            let delay = (BreakAnimation.shakeStepDuration * 3)
                + (TimeInterval(index % 3) * 0.018)
            let move = SKAction.moveBy(
                x: horizontalDirection * cellSize * (0.13 + CGFloat(index % 2) * 0.05),
                y: -cellSize * (0.16 + CGFloat(index % 3) * 0.04),
                duration: BreakAnimation.fragmentDuration
            )
            move.timingMode = .easeIn

            let rotation = SKAction.rotate(
                byAngle: horizontalDirection * (0.10 + CGFloat(index % 2) * 0.08),
                duration: BreakAnimation.fragmentDuration
            )
            let fade = SKAction.fadeOut(withDuration: BreakAnimation.fragmentDuration)
            let shrink = SKAction.scale(to: 0.76, duration: BreakAnimation.fragmentDuration)

            brick.run(.sequence([
                .wait(forDuration: delay),
                .group([move, rotation, fade, shrink])
            ]))
        }

        for crack in cover.children where crack.name == NodeName.crack {
            crack.run(.fadeOut(withDuration: 0.12))
        }

        addDust(to: cover, cellSize: cellSize)

        cover.run(.sequence([
            .wait(forDuration: BreakAnimation.totalDuration),
            .run { [weak cover] in
                cover?.removeFromParent()
                completion()
            }
        ]))
    }

    private func addBrick(
        to cover: SKNode,
        cell: BoardCell,
        course: Int,
        index: Int,
        size: CGSize,
        position: CGPoint
    ) {
        let colorIndex = abs(
            (cell.column * 3) + (cell.row * 5) + (course * 2) + index
        ) % brickColors.count

        let brick = SKSpriteNode(color: brickColors[colorIndex], size: size)
        brick.name = NodeName.brick
        brick.position = position
        brick.zPosition = 0

        let topHighlight = SKSpriteNode(
            color: brickHighlightColor,
            size: CGSize(width: max(2, size.width - 3), height: 1)
        )
        topHighlight.position = CGPoint(x: -0.5, y: (size.height / 2) - 1)
        topHighlight.zPosition = 0.1
        brick.addChild(topHighlight)

        let bottomShadow = SKSpriteNode(
            color: brickShadowColor,
            size: CGSize(width: size.width, height: 1)
        )
        bottomShadow.position = CGPoint(x: 0, y: -(size.height / 2) + 1)
        bottomShadow.zPosition = 0.1
        brick.addChild(bottomShadow)

        cover.addChild(brick)
    }

    private func addDeterministicCrack(
        to cover: SKNode,
        cell: BoardCell,
        cellSize: CGFloat
    ) {
        // 모든 칸에 금을 넣지 않고 주소를 기준으로 일부에만 넣어 반복 무늬를 줄입니다.
        guard ((cell.column * 7) + (cell.row * 11)).isMultiple(of: 5) else {
            return
        }

        let crack = SKNode()
        crack.name = NodeName.crack
        crack.position = CGPoint(
            x: cell.column.isMultiple(of: 2) ? -cellSize * 0.12 : cellSize * 0.14,
            y: cell.row.isMultiple(of: 2) ? cellSize * 0.10 : -cellSize * 0.12
        )
        crack.zPosition = 0.3

        let firstPixel = SKSpriteNode(
            color: brickShadowColor,
            size: CGSize(width: 4, height: 2)
        )
        firstPixel.position = CGPoint(x: -1, y: 1)
        crack.addChild(firstPixel)

        let secondPixel = SKSpriteNode(
            color: brickShadowColor,
            size: CGSize(width: 2, height: 4)
        )
        secondPixel.position = CGPoint(x: 1, y: -2)
        crack.addChild(secondPixel)

        cover.addChild(crack)
    }

    private func addDust(to cover: SKNode, cellSize: CGFloat) {
        for index in 0..<7 {
            let direction: CGFloat = index.isMultiple(of: 2) ? -1 : 1
            let dust = SKSpriteNode(
                color: brickColors[index % brickColors.count],
                size: CGSize(
                    width: index.isMultiple(of: 3) ? 4 : 3,
                    height: index.isMultiple(of: 2) ? 3 : 2
                )
            )
            dust.position = CGPoint(
                x: CGFloat((index % 3) - 1) * cellSize * 0.14,
                y: CGFloat(index % 2) * cellSize * 0.08
            )
            dust.zPosition = 0.5
            dust.alpha = 0
            cover.addChild(dust)

            let delay = (BreakAnimation.shakeStepDuration * 2)
                + (TimeInterval(index % 3) * 0.015)
            let appear = SKAction.fadeIn(withDuration: 0.02)
            let scatter = SKAction.moveBy(
                x: direction * cellSize * (0.16 + CGFloat(index % 3) * 0.04),
                y: cellSize * (0.06 + CGFloat(index % 2) * 0.08),
                duration: 0.20
            )
            scatter.timingMode = .easeOut

            dust.run(.sequence([
                .wait(forDuration: delay),
                appear,
                .group([
                    scatter,
                    .fadeOut(withDuration: 0.20),
                    .scale(to: 0.5, duration: 0.20)
                ])
            ]))
        }
    }
}
