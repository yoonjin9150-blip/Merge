//
//  SealedCellWallRenderer.swift
//  Merge
//
//  봉인된 칸을 하나로 이어진 황토 벽돌벽처럼 그립니다.
//

import SpriteKit

final class SealedCellWallRenderer {
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
}
