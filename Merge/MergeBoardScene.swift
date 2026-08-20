//
//  MergeBoardScene.swift
//  Merge
//
//  7 × 9 머지 보드와 보드 아이템을 보여 주는 SpriteKit 장면입니다.
//

import SpriteKit

final class MergeBoardScene: SKScene {

    // 생성기와 재료를 하나의 보드 아이템 타입으로 관리합니다.
    // 화면에 놓이는 대상은 같지만, 생성 여부와 머지 여부는 종류별 규칙으로 구분합니다.
    private enum BoardItemKind {
        case grainSack
        case wheat
        case flour

        var emoji: String {
            switch self {
            case .grainSack:
                // 곡물 포대 이미지가 준비되기 전까지 사용하는 임시 이모지입니다.
                return "🧺"
            case .wheat:
                return "🌾"
            case .flour:
                return "🥣"
            }
        }

        // 같은 재료 두 개를 머지했을 때 만들어질 다음 단계입니다.
        // 밀가루 이후 단계는 전체 머지 트리를 구현할 때 추가합니다.
        var nextKind: BoardItemKind? {
            switch self {
            case .grainSack:
                return nil
            case .wheat:
                return .flour
            case .flour:
                return nil
            }
        }

        // 생성기를 탭했을 때 만들어지는 아이템입니다.
        // 재료 아이템은 다른 아이템을 생성하지 않으므로 nil입니다.
        var spawnedItemKind: BoardItemKind? {
            switch self {
            case .grainSack:
                return .wheat
            case .wheat, .flour:
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

    // 생성기와 재료의 화면 표시, 현재 칸, 선택 상태를 함께 보관하는 보드 아이템 노드입니다.
    private final class BoardItemNode: SKLabelNode {
        let kind: BoardItemKind
        var cell: BoardCell
        var selectionIndicator: SKShapeNode?
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
    }

    // MARK: - 보드 규칙

    // 가로 칸 수입니다. Hollywood Merge와 같이 7칸으로 설정했습니다.
    private let columns = 7

    // 세로 칸 수입니다. Hollywood Merge와 같이 9칸으로 설정했습니다.
    private let rows = 9

    // 보드의 크기와 위치를 2pt 단위에 맞춰 픽셀 경계가 흐려지지 않게 합니다.
    private let pixelUnit: CGFloat = 2

    // 버터 스카이 픽셀 보드에서 공통으로 사용하는 색입니다.
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

    // 보드의 칸과 아이템을 담는 부모 노드입니다.
    private let boardNode = SKNode()

    // 화면 크기에 맞춰 계산되는 실제 한 칸의 크기입니다.
    private var cellSize: CGFloat = 0

    // 보드의 왼쪽 아래 시작점입니다.
    private var boardOrigin = CGPoint.zero

    // 마지막으로 선택한 아이템입니다.
    // 손가락을 떼어 드래그가 끝난 뒤에도 선택 표시와 함께 유지됩니다.
    private var selectedItem: BoardItemNode?

    // 현재 손가락으로 끌고 있는 아이템입니다.
    // touchesBegan에서 저장하고, 손가락을 떼면 nil로 초기화합니다.
    private var draggedItem: BoardItemNode?

    // 현재 드래그를 시작한 하나의 터치만 기억합니다.
    // 드래그 도중 다른 손가락이 화면에 닿아도 선택 아이템이 바뀌지 않게 합니다.
    private var activeTouch: UITouch?

    // 드래그를 시작한 칸입니다.
    // 손가락을 뗐을 때 빈 칸 이동·자리 교체·원래 칸 복귀를 판단하는 기준이 됩니다.
    private var originalCell: BoardCell?

    // 각 행·열에 어떤 아이템이 있는지 관리하는 실제 보드 상태입니다.
    // 아이템 노드의 화면 위치만 보고 빈 칸을 판단하지 않고, 이 딕셔너리를 기준으로 판단합니다.
    private var itemsByCell: [BoardCell: BoardItemNode] = [:]

    // 아이템을 잡은 지점과 아이템 중심 사이의 거리입니다.
    // 손가락을 아이템의 가장자리에서 눌러도 아이템이 갑자기 점프하지 않게 합니다.
    private var dragOffset = CGPoint.zero

    // 손가락이 이 거리 이상 움직이면 탭이 아니라 드래그로 판단합니다.
    // 작은 손떨림 때문에 생성기 탭이 드래그로 오인되지 않도록 여유를 둡니다.
    private let dragRecognitionDistance: CGFloat = 8

    // 현재 터치가 시작된 화면 좌표입니다. 이동 거리를 계산하는 기준입니다.
    private var touchStartLocation = CGPoint.zero

    // 현재 터치가 드래그 기준 거리를 넘었는지 기억합니다.
    private var didRecognizeDrag = false

    // 이번 터치가 시작되기 전부터 해당 아이템이 선택되어 있었는지 기억합니다.
    // touchesBegan에서 선택 표시를 숨긴 뒤에도 두 번째 탭인지 판단하기 위해 필요합니다.
    private var wasSelectedAtTouchStart = false

    // MARK: - Scene Life Cycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(boardNode)
        buildBoard()
    }

    // MARK: - Board Drawing

    private func buildBoard() {
        // 보드와 최초 아이템을 처음 그립니다.
        boardNode.removeAllChildren()
        itemsByCell.removeAll()
        selectedItem = nil
        draggedItem = nil
        activeTouch = nil
        originalCell = nil
        touchStartLocation = .zero
        didRecognizeDrag = false
        wasSelectedAtTouchStart = false

        // 보드의 바깥 여백입니다. 이 숫자를 바꾸면 보드와 화면 가장자리 사이가 바뀝니다.
        // 넓어진 픽셀 프레임까지 화면 안에 들어오도록 보드 자체에는 조금 더 여백을 둡니다.
        let horizontalPadding: CGFloat = 34
        let verticalPadding: CGFloat = 14

        let availableWidth = size.width - (horizontalPadding * 2)
        let availableHeight = size.height - (verticalPadding * 2)

        // 7 × 9 보드가 SpriteKit 영역 안에 모두 들어가도록 칸 크기를 계산합니다.
        // 계산 결과를 2pt 단위로 내림해 칸의 선과 중심이 픽셀 경계에 맞도록 합니다.
        let calculatedCellSize = min(
            availableWidth / CGFloat(columns),
            availableHeight / CGFloat(rows)
        )
        cellSize = floor(calculatedCellSize / pixelUnit) * pixelUnit

        let boardWidth = cellSize * CGFloat(columns)
        let boardHeight = cellSize * CGFloat(rows)

        // 보드 전체가 SpriteKit 영역의 중앙에 오도록 시작점을 계산합니다.
        boardOrigin = CGPoint(
            x: ((size.width - boardWidth) / 2).rounded(),
            y: ((size.height - boardHeight) / 2).rounded()
        )

        drawBoardFrame(width: boardWidth, height: boardHeight)
        drawCells()
        addInitialItems()
        assertBoardItemsMatchStoredCells()
    }

    private func drawBoardFrame(width: CGFloat, height: CGFloat) {
        let boardCenter = CGPoint(
            x: boardOrigin.x + (width / 2),
            y: boardOrigin.y + (height / 2)
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

        addFrameHighlights(boardCenter: boardCenter, boardWidth: width, boardHeight: height)

        // 각 타일 사이의 가는 남색 선으로 보이는 내부 바탕입니다.
        let gridBackground = SKSpriteNode(
            color: outlineColor,
            size: CGSize(width: width + 2, height: height + 2)
        )
        gridBackground.position = boardCenter
        gridBackground.zPosition = -1
        boardNode.addChild(gridBackground)

        addFrameStuds(boardCenter: boardCenter, boardWidth: width, boardHeight: height)
        addCenterTabs(boardCenter: boardCenter, boardHeight: height)
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

    private func addCenterTabs(boardCenter: CGPoint, boardHeight: CGFloat) {
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

    private func drawCells() {
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
                cellTile.position = positionForCell(column: column, row: row)
                cellTile.zPosition = 0
                cellTile.name = "boardCell"

                // 타일 위쪽에는 밝은 1pt 선, 아래쪽에는 베이지 2pt 선을 넣어
                // 평면 사각형이 아니라 살짝 도톰한 픽셀 타일처럼 보이게 합니다.
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

        addGridIntersections()
    }

    private func addGridIntersections() {
        // 레퍼런스의 격자 교차점은 선보다 한 픽셀 더 굵은 작은 남색 사각형입니다.
        // 칸의 경계가 만나는 내부 지점에만 추가하며, 행·열과 터치 판정에는 영향을 주지 않습니다.
        for rowBoundary in 1..<rows {
            for columnBoundary in 1..<columns {
                let intersection = SKSpriteNode(
                    color: outlineColor,
                    size: CGSize(width: 3, height: 3)
                )
                intersection.position = CGPoint(
                    x: boardOrigin.x + (CGFloat(columnBoundary) * cellSize),
                    y: boardOrigin.y + (CGFloat(rowBoundary) * cellSize)
                )
                intersection.zPosition = 0.2
                intersection.name = "gridIntersection"
                boardNode.addChild(intersection)
            }
        }
    }

    // MARK: - Initial Board Items

    private func addInitialItems() {
        // row 0은 화면에서 가장 위쪽인 1행입니다.
        // column 0은 왼쪽 첫 번째 칸입니다.
        // 곡물 포대는 최초 상태에서 좌측 상단 1행 1열 한 칸만 차지합니다.
        addBoardItem(
            .grainSack,
            column: 0,
            row: 0
        )
    }

    @discardableResult
    private func addBoardItem(
        _ kind: BoardItemKind,
        column: Int,
        row: Int
    ) -> BoardItemNode {
        let cell = BoardCell(column: column, row: row)

        // 같은 칸에 두 노드를 추가하면 화면과 itemsByCell이 어긋납니다.
        // 호출하는 쪽은 반드시 빈 칸을 확인하거나 기존 아이템을 제거한 뒤 추가해야 합니다.
        precondition(itemsByCell[cell] == nil, "이미 아이템이 있는 칸에는 새 아이템을 추가할 수 없습니다.")

        let item = BoardItemNode(
            kind: kind,
            cell: cell
        )

        item.fontSize = cellSize * 0.58
        item.verticalAlignmentMode = .center
        item.horizontalAlignmentMode = .center
        item.position = positionForCell(cell)
        item.zPosition = 1
        item.name = "boardItem"

        // 선택 상태를 눈으로 검증하기 위한 임시 표시입니다.
        // 실제 디자인은 이후 UI 작업에서 교체합니다.
        let selectionIndicator = makeSelectionIndicator()
        item.addChild(selectionIndicator)
        item.selectionIndicator = selectionIndicator

        boardNode.addChild(item)
        itemsByCell[cell] = item
        return item
    }

    // MARK: - Touch Drag

    // 손가락을 화면에 댄 순간입니다.
    // 터치 위치에 보드 아이템이 있으면, 그 아이템을 이번 드래그의 대상으로 저장합니다.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 이미 한 아이템을 드래그 중이라면 추가 터치는 무시합니다.
        guard activeTouch == nil, draggedItem == nil, let touch = touches.first else {
            return
        }

        let touchLocation = touch.location(in: self)
        guard let item = boardItemNode(at: touchLocation) else {
            return
        }

        // 선택 표시를 숨기기 전에, 이번 터치가 선택된 아이템을 다시 누른 것인지 저장합니다.
        wasSelectedAtTouchStart = selectedItem === item && item.isSelected

        // 손가락으로 누르고 드래그하는 동안에는 꼭짓점 선택 표시를 숨깁니다.
        // 움직이지 않고 탭한 경우에도 손가락을 뗀 뒤 다시 표시합니다.
        clearSelection()
        activeTouch = touch
        draggedItem = item
        originalCell = item.cell
        touchStartLocation = touchLocation
        didRecognizeDrag = false
        dragOffset = CGPoint(
            x: item.position.x - touchLocation.x,
            y: item.position.y - touchLocation.y
        )

        // 드래그 중인 아이템이 다른 칸보다 앞에 보이도록 합니다.
        item.zPosition = 2
    }

    // 손가락을 누른 채 움직이는 동안 계속 호출됩니다.
    // 드래그 중인 재료를 손가락 위치로 옮기되, 재료 전체가 보드 안에 남도록 제한합니다.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let activeTouch,
              touches.contains(where: { $0 === activeTouch }),
              let item = draggedItem else {
            return
        }

        let touchLocation = activeTouch.location(in: self)

        // 기준 거리보다 적게 움직였다면 아직 탭일 수 있으므로 아이템을 움직이지 않습니다.
        guard recognizeDragIfNeeded(at: touchLocation) else {
            return
        }

        let proposedPosition = CGPoint(
            x: touchLocation.x + dragOffset.x,
            y: touchLocation.y + dragOffset.y
        )

        item.position = constrainedPosition(for: item, proposedPosition: proposedPosition)
    }

    // 손가락을 뗀 순간입니다.
    // 현재 아이템 중심에서 가장 가까운 칸을 찾고, 그 칸의 점유 상태에 따라 스냅합니다.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 드래그를 시작한 손가락을 뗐을 때만 드롭을 처리합니다.
        // 도중에 추가로 닿은 다른 손가락을 떼는 것은 무시합니다.
        guard let activeTouch,
              touches.contains(where: { $0 === activeTouch }) else {
            return
        }

        guard let item = draggedItem, let startCell = originalCell else {
            finishDragging()
            return
        }

        let touchEndLocation = activeTouch.location(in: self)

        // 손을 뗀 최종 위치까지 확인해 드래그 기준 거리보다 적게 움직였다면 탭으로 처리합니다.
        if !recognizeDragIfNeeded(at: touchEndLocation) {
            let shouldActivateGenerator = wasSelectedAtTouchStart
            item.position = positionForCell(startCell)
            finishDragging()
            select(item)

            // 첫 번째 탭은 선택만 합니다.
            // 이미 선택된 생성기를 다시 탭했을 때만 빈 칸에 아이템을 생성합니다.
            if shouldActivateGenerator {
                spawnItemIfPossible(from: item)
            }

            assertBoardItemsMatchStoredCells()
            return
        }

        // 마지막 touchesMoved 이후 손가락이 더 움직였을 수 있으므로 최종 위치를 한 번 더 반영합니다.
        let finalPosition = CGPoint(
            x: touchEndLocation.x + dragOffset.x,
            y: touchEndLocation.y + dragOffset.y
        )
        item.position = constrainedPosition(for: item, proposedPosition: finalPosition)

        let targetCell = nearestCell(to: item.position)
        let itemToSelect = resolveDrop(of: item, from: startCell, to: targetCell)
        finishDragging()
        // 손가락 드래그 상태를 먼저 종료한 뒤, 머지 결과 아이템을 선택 상태로 유지합니다.
        select(itemToSelect)
        assertBoardItemsMatchStoredCells()
    }

    // 전화 수신 등으로 터치가 취소되면 보드 상태를 바꾸지 않고 원래 칸으로 돌려놓습니다.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let activeTouch,
              touches.contains(where: { $0 === activeTouch }) else {
            return
        }

        let itemToSelect = draggedItem

        if let item = itemToSelect, let startCell = originalCell {
            item.position = positionForCell(startCell)
        }

        finishDragging()
        // 시스템이 터치를 취소하면 원래 칸으로 돌아간 아이템에 선택 표시를 복구합니다.
        if let itemToSelect {
            select(itemToSelect)
        }
        assertBoardItemsMatchStoredCells()
    }

    private func recognizeDragIfNeeded(at touchLocation: CGPoint) -> Bool {
        if didRecognizeDrag {
            return true
        }

        let horizontalDistance = touchLocation.x - touchStartLocation.x
        let verticalDistance = touchLocation.y - touchStartLocation.y
        let squaredDistance = (horizontalDistance * horizontalDistance)
            + (verticalDistance * verticalDistance)
        let squaredThreshold = dragRecognitionDistance * dragRecognitionDistance

        if squaredDistance >= squaredThreshold {
            didRecognizeDrag = true
        }

        return didRecognizeDrag
    }

    // MARK: - Generator

    private func spawnItemIfPossible(from generator: BoardItemNode) {
        // 생성기 종류가 무엇을 만드는지 확인합니다.
        // 밀·밀가루 같은 일반 재료를 다시 탭한 경우에는 아무것도 생성하지 않습니다.
        guard let spawnedKind = generator.kind.spawnedItemKind,
              let emptyCell = firstEmptyCell() else {
            return
        }

        // 빈 칸을 찾은 뒤 화면 노드와 itemsByCell 상태를 동시에 추가합니다.
        // 생성 애니메이션은 후속 작업에서 이 지점에 연결합니다.
        addBoardItem(
            spawnedKind,
            column: emptyCell.column,
            row: emptyCell.row
        )
    }

    private func firstEmptyCell() -> BoardCell? {
        // row 0의 왼쪽부터 오른쪽으로 확인한 뒤 다음 행으로 내려갑니다.
        // 따라서 최초 곡물 포대가 1행 1열을 차지하면 첫 밀은 1행 2열에 생성됩니다.
        for row in 0..<rows {
            for column in 0..<columns {
                let cell = BoardCell(column: column, row: row)

                if itemsByCell[cell] == nil {
                    return cell
                }
            }
        }

        // 63칸이 모두 차 있으면 기존 아이템을 덮어쓰지 않고 생성을 취소합니다.
        return nil
    }

    // MARK: - Grid Snap

    private func resolveDrop(
        of draggedItem: BoardItemNode,
        from startCell: BoardCell,
        to targetCell: BoardCell
    ) -> BoardItemNode {
        // 시작한 칸에 다시 놓았다면 데이터는 바꾸지 않고 칸 중앙에 정확히 맞춥니다.
        guard targetCell != startCell else {
            draggedItem.position = positionForCell(startCell)
            return draggedItem
        }

        // 목표 칸이 비었다면 시작 칸을 비우고 목표 칸에 아이템을 등록합니다.
        // 화면 위치와 보드 상태를 같은 시점에 갱신해야 둘이 어긋나지 않습니다.
        guard let targetItem = itemsByCell[targetCell] else {
            itemsByCell[startCell] = nil
            itemsByCell[targetCell] = draggedItem
            draggedItem.cell = targetCell
            draggedItem.position = positionForCell(targetCell)
            return draggedItem
        }

        // 같은 재료이고 다음 단계가 있다면 두 아이템을 다음 단계 하나로 머지합니다.
        // 이번 기술 검증에서는 밀 두 개만 밀가루로 바뀝니다.
        if draggedItem.kind == targetItem.kind,
           let nextKind = draggedItem.kind.nextKind {
            return mergeItems(
                draggedItem,
                with: targetItem,
                from: startCell,
                at: targetCell,
                into: nextKind
            )
        }

        // 다른 종류·다른 단계이거나 다음 단계가 없는 아이템은 서로 위치를 교체합니다.
        swapItems(draggedItem, with: targetItem, from: startCell, to: targetCell)
        return draggedItem
    }

    private func mergeItems(
        _ draggedItem: BoardItemNode,
        with targetItem: BoardItemNode,
        from startCell: BoardCell,
        at targetCell: BoardCell,
        into nextKind: BoardItemKind
    ) -> BoardItemNode {
        // 먼저 두 칸의 기존 점유 정보를 제거합니다.
        // 화면 노드를 제거한 뒤 딕셔너리에 남는 유령 아이템이 없도록 함께 갱신합니다.
        itemsByCell[startCell] = nil
        itemsByCell[targetCell] = nil

        draggedItem.removeFromParent()
        targetItem.removeFromParent()

        // 머지 결과는 사용자가 드롭한 목표 칸에 하나만 생성합니다.
        // addBoardItem이 새 노드를 화면과 itemsByCell에 동시에 등록합니다.
        return addBoardItem(
            nextKind,
            column: targetCell.column,
            row: targetCell.row
        )
    }

    private func swapItems(
        _ draggedItem: BoardItemNode,
        with targetItem: BoardItemNode,
        from startCell: BoardCell,
        to targetCell: BoardCell
    ) {
        // 두 칸의 점유 상태를 교체한 뒤 두 화면 노드도 각 칸 중앙에 배치합니다.
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
        draggedItem?.zPosition = 1
        activeTouch = nil
        draggedItem = nil
        originalCell = nil
        dragOffset = .zero
        touchStartLocation = .zero
        didRecognizeDrag = false
        wasSelectedAtTouchStart = false
    }

    // MARK: - Debug Validation

    private func assertBoardItemsMatchStoredCells() {
#if DEBUG
        // 화면에 보이는 보드 아이템과 itemsByCell에 저장된 아이템의 개수가 같은지 확인합니다.
        let visibleItems = boardNode.children.compactMap { $0 as? BoardItemNode }
        assert(
            visibleItems.count == itemsByCell.count,
            "화면의 아이템 개수와 itemsByCell에 저장된 아이템 개수가 다릅니다."
        )

        // 화면에 보이는 각 아이템이 자신의 cell 주소로 itemsByCell에도 등록되어 있는지 확인합니다.
        for item in visibleItems {
            guard let storedItem = itemsByCell[item.cell] else {
                assertionFailure("화면에는 아이템이 있지만 해당 칸이 itemsByCell에 저장되어 있지 않습니다.")
                continue
            }

            assert(
                storedItem === item,
                "화면의 아이템과 itemsByCell에 저장된 아이템이 서로 다른 객체입니다."
            )
        }

        // itemsByCell의 칸 주소, 아이템이 기억하는 cell, 실제 화면 존재 여부가 모두 같은지 확인합니다.
        for (cell, item) in itemsByCell {
            assert((0..<columns).contains(cell.column), "보드 범위를 벗어난 열에 아이템이 저장되었습니다.")
            assert((0..<rows).contains(cell.row), "보드 범위를 벗어난 행에 아이템이 저장되었습니다.")
            assert(item.cell == cell, "itemsByCell의 칸과 아이템이 기억하는 칸이 다릅니다.")
            assert(item.parent === boardNode, "itemsByCell에는 아이템이 있지만 화면에는 존재하지 않습니다.")
        }

        assert(itemsByCell.count <= columns * rows, "보드의 전체 칸 수보다 많은 아이템이 저장되었습니다.")

        if let selectedItem {
            assert(selectedItem.parent === boardNode, "선택된 아이템이 화면에 존재하지 않습니다.")
        }
#endif
    }

    // MARK: - Selection

    private func makeSelectionIndicator() -> SKShapeNode {
        let path = CGMutablePath()

        // 아이템 중심에서 선택 표시 꼭짓점까지의 거리입니다.
        // 값을 키우면 네 개의 ㄱ자 표시가 아이템에서 더 멀어집니다.
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
        // 아이템보다 앞에 그려 선택 여부가 항상 보이도록 합니다.
        indicator.zPosition = 1
        indicator.isHidden = true
        indicator.name = "selectionIndicator"
        return indicator
    }

    private func select(_ item: BoardItemNode) {
        clearSelection()
        selectedItem = item
        item.isSelected = true
    }

    private func clearSelection() {
        selectedItem?.isSelected = false
        selectedItem = nil
    }

    private func boardItemNode(at position: CGPoint) -> BoardItemNode? {
        // 선택 테두리는 아이템의 자식 노드이므로, 테두리를 눌러도 부모 아이템을 찾도록 위로 탐색합니다.
        var node: SKNode? = atPoint(position)

        while let currentNode = node {
            if let item = currentNode as? BoardItemNode,
               item.name == "boardItem" {
                return item
            }

            node = currentNode.parent
        }

        return nil
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
