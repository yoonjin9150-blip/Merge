//
//  BoardRenderer.swift
//  Merge
//
//  버터 스카이 픽셀 보드의 프레임과 격자를 그립니다.
//

import SpriteKit

final class BoardRenderer {
    private let outlineColor = SKColor(red: 0.07, green: 0.08, blue: 0.22, alpha: 1)
    private let frameColor = SKColor(red: 1, green: 0.82, blue: 0.28, alpha: 1)
    private let frameHighlightColor = SKColor(red: 1, green: 0.91, blue: 0.48, alpha: 1)
    private let frameShadeColor = SKColor(red: 0.96, green: 0.64, blue: 0.14, alpha: 1)
    private let shadowColor = SKColor(red: 0.20, green: 0.38, blue: 0.56, alpha: 0.58)
    private let coralColor = SKColor(red: 1, green: 0.43, blue: 0.35, alpha: 1)
    private let creamColor = SKColor(red: 1, green: 0.96, blue: 0.83, alpha: 1)
    private let tileHighlightColor = SKColor(red: 1, green: 0.99, blue: 0.92, alpha: 1)
    private let tileShadeColor = SKColor(red: 0.98, green: 0.91, blue: 0.74, alpha: 1)
    private let studHighlightColor = SKColor(red: 1, green: 0.73, blue: 0.61, alpha: 1)

    func drawBoard(
        on boardNode: SKNode,
        origin: CGPoint,
        cellSize: CGFloat,
        columns: Int,
        rows: Int
    ) {
        let boardWidth = cellSize * CGFloat(columns)
        let boardHeight = cellSize * CGFloat(rows)

        drawBoardFrame(
            on: boardNode,
            origin: origin,
            width: boardWidth,
            height: boardHeight
        )
        drawCells(
            on: boardNode,
            origin: origin,
            cellSize: cellSize,
            columns: columns,
            rows: rows
        )
    }

    private func drawBoardFrame(
        on boardNode: SKNode,
        origin: CGPoint,
        width: CGFloat,
        height: CGFloat
    ) {
        let boardCenter = CGPoint(
            x: origin.x + (width / 2),
            y: origin.y + (height / 2)
        )

        // 오른쪽 아래로 살짝 밀린 그림자가 보드 외곽의 계단 모양을 그대로 따라갑니다.
        let shadow = makeSteppedPanel(
            size: CGSize(width: width + 36, height: height + 36),
            cornerCut: 10,
            color: shadowColor
        )
        shadow.position = CGPoint(x: boardCenter.x + 6, y: boardCenter.y - 6)
        shadow.zPosition = -6
        boardNode.addChild(shadow)

        // 가장 바깥의 짙은 남색 픽셀 외곽선입니다.
        let outerOutline = makeSteppedPanel(
            size: CGSize(width: width + 36, height: height + 36),
            cornerCut: 10,
            color: outlineColor
        )
        outerOutline.position = boardCenter
        outerOutline.zPosition = -5
        boardNode.addChild(outerOutline)

        // 버터 프레임 아래쪽에 진한 노랑 층을 깔아 픽셀 장난감 같은 깊이를 만듭니다.
        let frameShade = makeSteppedPanel(
            size: CGSize(width: width + 30, height: height + 30),
            cornerCut: 8,
            color: frameShadeColor
        )
        frameShade.position = boardCenter
        frameShade.zPosition = -4
        boardNode.addChild(frameShade)

        // 외곽선 안쪽의 넓은 버터 노랑 프레임입니다.
        let butterFrame = makeSteppedPanel(
            size: CGSize(width: width + 26, height: height + 26),
            cornerCut: 8,
            color: frameColor
        )
        butterFrame.position = boardCenter
        butterFrame.zPosition = -3
        boardNode.addChild(butterFrame)

        addFrameHighlights(
            to: boardNode,
            boardCenter: boardCenter,
            boardWidth: width,
            boardHeight: height
        )

        // 각 타일 사이의 가는 남색 선으로 보이는 내부 바탕입니다.
        let gridBackground = SKSpriteNode(
            color: outlineColor,
            size: CGSize(width: width + 2, height: height + 2)
        )
        gridBackground.position = boardCenter
        gridBackground.zPosition = -1
        boardNode.addChild(gridBackground)

        addFrameStuds(
            to: boardNode,
            boardCenter: boardCenter,
            boardWidth: width,
            boardHeight: height
        )
        addCenterTabs(
            to: boardNode,
            boardCenter: boardCenter,
            boardHeight: height
        )
    }

    private func makeSteppedPanel(
        size: CGSize,
        cornerCut: CGFloat,
        color: SKColor
    ) -> SKShapeNode {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        let path = CGMutablePath()

        // 대각선을 쓰지 않고 수평·수직선만 이어 네 모서리를 계단식으로 잘라냅니다.
        path.move(to: CGPoint(x: -halfWidth + cornerCut, y: halfHeight))
        path.addLine(to: CGPoint(x: halfWidth - cornerCut, y: halfHeight))
        path.addLine(to: CGPoint(x: halfWidth - cornerCut, y: halfHeight - cornerCut))
        path.addLine(to: CGPoint(x: halfWidth, y: halfHeight - cornerCut))
        path.addLine(to: CGPoint(x: halfWidth, y: -halfHeight + cornerCut))
        path.addLine(to: CGPoint(x: halfWidth - cornerCut, y: -halfHeight + cornerCut))
        path.addLine(to: CGPoint(x: halfWidth - cornerCut, y: -halfHeight))
        path.addLine(to: CGPoint(x: -halfWidth + cornerCut, y: -halfHeight))
        path.addLine(to: CGPoint(x: -halfWidth + cornerCut, y: -halfHeight + cornerCut))
        path.addLine(to: CGPoint(x: -halfWidth, y: -halfHeight + cornerCut))
        path.addLine(to: CGPoint(x: -halfWidth, y: halfHeight - cornerCut))
        path.addLine(to: CGPoint(x: -halfWidth + cornerCut, y: halfHeight - cornerCut))
        path.closeSubpath()

        let panel = SKShapeNode(path: path)
        panel.fillColor = color
        panel.strokeColor = .clear
        panel.isAntialiased = false
        return panel
    }

    private func addFrameStuds(
        to boardNode: SKNode,
        boardCenter: CGPoint,
        boardWidth: CGFloat,
        boardHeight: CGFloat
    ) {
        let horizontalOffset = (boardWidth / 2) + 9
        let verticalOffset = (boardHeight / 2) + 9
        let studPositions = [
            CGPoint(x: boardCenter.x - horizontalOffset, y: boardCenter.y + verticalOffset),
            CGPoint(x: boardCenter.x + horizontalOffset, y: boardCenter.y + verticalOffset),
            CGPoint(x: boardCenter.x - horizontalOffset, y: boardCenter.y - verticalOffset),
            CGPoint(x: boardCenter.x + horizontalOffset, y: boardCenter.y - verticalOffset)
        ]

        for position in studPositions {
            let studOutline = SKSpriteNode(
                color: outlineColor,
                size: CGSize(width: 10, height: 10)
            )
            studOutline.position = position
            studOutline.zPosition = -0.7

            let studCenter = SKSpriteNode(
                color: coralColor,
                size: CGSize(width: 6, height: 6)
            )
            studCenter.zPosition = 0.1

            let studGlint = SKSpriteNode(
                color: studHighlightColor,
                size: CGSize(width: 2, height: 2)
            )
            studGlint.position = CGPoint(x: -1, y: 1)
            studGlint.zPosition = 0.1
            studCenter.addChild(studGlint)
            studOutline.addChild(studCenter)
            boardNode.addChild(studOutline)
        }
    }

    private func addFrameHighlights(
        to boardNode: SKNode,
        boardCenter: CGPoint,
        boardWidth: CGFloat,
        boardHeight: CGFloat
    ) {
        // 위쪽과 왼쪽의 밝은 띠는 프레임이 빛을 받는 면을 표현합니다.
        let topHighlight = SKSpriteNode(
            color: frameHighlightColor,
            size: CGSize(width: boardWidth - 12, height: 3)
        )
        topHighlight.position = CGPoint(
            x: boardCenter.x,
            y: boardCenter.y + (boardHeight / 2) + 9
        )
        topHighlight.zPosition = -2
        boardNode.addChild(topHighlight)

        let leftHighlight = SKSpriteNode(
            color: frameHighlightColor,
            size: CGSize(width: 3, height: boardHeight - 12)
        )
        leftHighlight.position = CGPoint(
            x: boardCenter.x - (boardWidth / 2) - 9,
            y: boardCenter.y
        )
        leftHighlight.zPosition = -2
        boardNode.addChild(leftHighlight)

        // 아래쪽과 오른쪽의 주황 띠는 빛이 닿지 않는 면을 표현합니다.
        let bottomShade = SKSpriteNode(
            color: frameShadeColor,
            size: CGSize(width: boardWidth - 12, height: 3)
        )
        bottomShade.position = CGPoint(
            x: boardCenter.x,
            y: boardCenter.y - (boardHeight / 2) - 9
        )
        bottomShade.zPosition = -2
        boardNode.addChild(bottomShade)

        let rightShade = SKSpriteNode(
            color: frameShadeColor,
            size: CGSize(width: 3, height: boardHeight - 12)
        )
        rightShade.position = CGPoint(
            x: boardCenter.x + (boardWidth / 2) + 9,
            y: boardCenter.y
        )
        rightShade.zPosition = -2
        boardNode.addChild(rightShade)
    }

    private func addCenterTabs(
        to boardNode: SKNode,
        boardCenter: CGPoint,
        boardHeight: CGFloat
    ) {
        // A안 레퍼런스처럼 위·아래 중앙에 프레임 밖으로 살짝 튀어나온 장식을 둡니다.
        let verticalOffset = (boardHeight / 2) + 17

        for direction in [-1.0, 1.0] {
            let tabOutline = SKSpriteNode(
                color: outlineColor,
                size: CGSize(width: 24, height: 12)
            )
            tabOutline.position = CGPoint(
                x: boardCenter.x,
                y: boardCenter.y + (verticalOffset * direction)
            )
            tabOutline.zPosition = -0.7

            let tabFrame = SKSpriteNode(
                color: frameColor,
                size: CGSize(width: 18, height: 8)
            )
            tabFrame.zPosition = 0.1
            tabOutline.addChild(tabFrame)

            let tabCenter = SKSpriteNode(
                color: coralColor,
                size: CGSize(width: 6, height: 6)
            )
            tabCenter.zPosition = 0.2

            let tabGlint = SKSpriteNode(
                color: studHighlightColor,
                size: CGSize(width: 2, height: 2)
            )
            tabGlint.position = CGPoint(x: -1, y: 1)
            tabGlint.zPosition = 0.1
            tabCenter.addChild(tabGlint)
            tabOutline.addChild(tabCenter)
            boardNode.addChild(tabOutline)
        }
    }

    private func drawCells(
        on boardNode: SKNode,
        origin: CGPoint,
        cellSize: CGFloat,
        columns: Int,
        rows: Int
    ) {
        for row in 0..<rows {
            for column in 0..<columns {
                // 레퍼런스처럼 네 모서리를 2pt만큼 잘라낸 크림색 픽셀 타일입니다.
                // 칸보다 2pt 작아서 뒤의 남색 바탕이 가는 격자선으로 보입니다.
                let tileSize = CGSize(width: cellSize - 2, height: cellSize - 2)
                let cellTile = makeSteppedPanel(
                    size: tileSize,
                    cornerCut: 2,
                    color: creamColor
                )
                cellTile.position = positionForCell(
                    column: column,
                    row: row,
                    origin: origin,
                    cellSize: cellSize,
                    rows: rows
                )
                cellTile.zPosition = 0
                cellTile.name = "boardCell"

                let topHighlight = SKSpriteNode(
                    color: tileHighlightColor,
                    size: CGSize(width: cellSize - 6, height: 1)
                )
                topHighlight.position = CGPoint(x: 0, y: (tileSize.height / 2) - 1.5)
                topHighlight.zPosition = 0.1
                cellTile.addChild(topHighlight)

                let bottomShade = SKSpriteNode(
                    color: tileShadeColor,
                    size: CGSize(width: cellSize - 6, height: 1)
                )
                bottomShade.position = CGPoint(x: 0, y: -(tileSize.height / 2) + 1.5)
                bottomShade.zPosition = 0.1
                cellTile.addChild(bottomShade)

                boardNode.addChild(cellTile)
            }
        }

        addGridIntersections(
            to: boardNode,
            origin: origin,
            cellSize: cellSize,
            columns: columns,
            rows: rows
        )
    }

    private func addGridIntersections(
        to boardNode: SKNode,
        origin: CGPoint,
        cellSize: CGFloat,
        columns: Int,
        rows: Int
    ) {
        // 칸의 경계가 만나는 내부 지점에만 교차점 픽셀을 추가합니다.
        for rowBoundary in 1..<rows {
            for columnBoundary in 1..<columns {
                let intersection = SKSpriteNode(
                    color: outlineColor,
                    size: CGSize(width: 3, height: 3)
                )
                intersection.position = CGPoint(
                    x: origin.x + (CGFloat(columnBoundary) * cellSize),
                    y: origin.y + (CGFloat(rowBoundary) * cellSize)
                )
                intersection.zPosition = 0.2
                intersection.name = "gridIntersection"
                boardNode.addChild(intersection)
            }
        }
    }

    private func positionForCell(
        column: Int,
        row: Int,
        origin: CGPoint,
        cellSize: CGFloat,
        rows: Int
    ) -> CGPoint {
        let x = origin.x + (CGFloat(column) + 0.5) * cellSize
        let y = origin.y + (CGFloat(rows - row) - 0.5) * cellSize
        return CGPoint(x: x, y: y)
    }
}
