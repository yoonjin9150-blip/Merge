//
//  MergeBoardScene.swift
//  Merge
//
//  7 × 9 머지 보드와 보드 아이템을 보여 주는 SpriteKit 장면입니다.
//

import SpriteKit
import UIKit

struct BoardDeliveryItem {
    let kind: BoardItemKind
    let scenePosition: CGPoint
}

enum CookingPotSelectionState: Equatable {
    case loaded(BoardItemKind)
    case cooking
}

final class MergeBoardScene: SKScene {

    private struct DropResolution {
        let itemToSelect: BoardItemNode
        let shouldPlayMergeFeedback: Bool
    }

    private enum MergeAnimation {
        static let initialScale: CGFloat = 0.65
        static let peakScale: CGFloat = 1.15
        static let growDuration: TimeInterval = 0.12
        static let settleDuration: TimeInterval = 0.10
    }

    private enum SpawnAnimation {
        static let duration: TimeInterval = 0.25
        static let effectNodeName = "spawnAnimation"
        static let effectZPosition: CGFloat = 3
    }

    private enum CookingAnimation {
        static let shakeDistance: CGFloat = 3
        static let shakeStepDuration: TimeInterval = 0.07
        static let shakeCount = 5
        static let foodTravelDuration: TimeInterval = 0.34
    }

    // MARK: - 보드 규칙

    // 가로 칸 수입니다. Hollywood Merge와 같이 7칸으로 설정했습니다.
    private let columns = 7

    // 세로 칸 수입니다. Hollywood Merge와 같이 9칸으로 설정했습니다.
    private let rows = 9

    // 보드의 크기와 위치를 2pt 단위에 맞춰 픽셀 경계가 흐려지지 않게 합니다.
    private let pixelUnit: CGFloat = 2

    // 보드의 칸과 아이템을 담는 부모 노드입니다.
    private let boardNode = SKNode()

    // 픽셀 프레임과 7×9 격자를 그리는 전용 객체입니다.
    private let boardRenderer = BoardRenderer()

    // 각 칸의 점유 상태와 아이템 이동·교체를 관리하는 전용 객체입니다.
    private lazy var boardState = BoardState(columns: columns, rows: rows)

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

    // 머지 결과가 통통 튀는 동안 새로운 보드 입력을 막습니다.
    // BoardState는 이미 갱신된 상태이므로 짧은 연출 중 중복 조작만 방지합니다.
    private var isMergeFeedbackRunning = false

    // 머지 결과 단계에 맞는 음계와 soft 햅틱을 함께 재생합니다.
    private let mergeFeedbackPlayer = MergeFeedbackPlayer()

    // 생성기 스폰 등 머지가 아닌 짧은 게임 효과음을 재생합니다.
    private let gameSoundPlayer = GameSoundPlayer()

    // SwiftUI가 소유한 에너지 상태에 성공할 스폰의 비용 차감을 요청합니다.
    // nil이거나 에너지가 부족해 false를 반환하면 아이템을 생성하지 않습니다.
    var consumeEnergyForSpawn: (() -> Bool)?

    // 상점에서 영구 구매한 보드 아이템 종류입니다.
    // 장면이 만들어지기 전 전달되어도 buildBoard에서 복원하고, 실행 중 바뀌면 즉시 빈 칸에 배치합니다.
    var purchasedPermanentItemKinds: [BoardItemKind] = [] {
        didSet {
            restorePurchasedPermanentItemsIfPossible()
        }
    }

    // 활성 주문의 완성품과 재료에 해당하는 아이템 종류입니다.
    // 값이 바뀌면 현재 보드의 모든 아이템 체크 표시를 다시 계산합니다.
    var activeOrderItemKinds: Set<BoardItemKind> = [] {
        didSet {
            refreshOrderCheckIndicators()
        }
    }

    // 보드 아이템 개수가 바뀔 때 SwiftUI 주문 목록에 최신 상태를 전달합니다.
    var onBoardItemCountsChanged: (([BoardItemKind: Int]) -> Void)? {
        didSet {
            publishBoardItemState()
        }
    }

    // 선택한 냄비의 상태를 SwiftUI 하단 조리 패널에 전달합니다.
    var onCookingPotSelectionChanged: ((CookingPotSelectionState?) -> Void)? {
        didSet {
            publishCookingPotSelection()
        }
    }

    // MARK: - Scene Life Cycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(boardNode)
        buildBoard()
        mergeFeedbackPlayer.prepare()
    }

    // MARK: - Board Drawing

    private func buildBoard() {
        // 보드와 최초 아이템을 처음 그립니다.
        boardNode.removeAllChildren()
        boardState.reset()
        selectedItem = nil
        draggedItem = nil
        activeTouch = nil
        originalCell = nil
        touchStartLocation = .zero
        didRecognizeDrag = false
        wasSelectedAtTouchStart = false
        isMergeFeedbackRunning = false

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

        boardRenderer.drawBoard(
            on: boardNode,
            origin: boardOrigin,
            cellSize: cellSize,
            columns: columns,
            rows: rows
        )
        addInitialItems()
        restorePurchasedPermanentItemsIfPossible()
        publishBoardItemState()
        assertBoardItemsMatchStoredCells()
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

        // 첫 번째 검증에서는 잠긴 밀 하나만 둡니다.
        // 곡물 포대에서 만든 밀을 이 칸에 놓아 잠금 해제와 한 단계 머지를 함께 확인합니다.
        addBoardItem(
            .wheat,
            column: 1,
            row: 0,
            isLocked: true
        )
    }

    // 상점 구매 전에 사용할 수 있는 빈 칸이 있고, 같은 영구 아이템이 아직 없는지 확인합니다.
    func canPlacePermanentItem(_ kind: BoardItemKind) -> Bool {
        (kind.isCookingTool || kind == .jangdokdae)
            && boardNode.parent != nil
            && boardState.items(of: kind).isEmpty
            && boardState.firstEmptyCell() != nil
    }

    // 구매가 성공한 조리도구를 화면 위쪽 행, 왼쪽 열부터 찾은 첫 빈 칸에 배치합니다.
    // 화면 노드와 BoardState를 addBoardItem 한 번으로 함께 갱신합니다.
    @discardableResult
    func placePermanentItemIfPossible(_ kind: BoardItemKind) -> Bool {
        guard canPlacePermanentItem(kind),
              let emptyCell = boardState.firstEmptyCell() else {
            return false
        }

        addBoardItem(
            kind,
            column: emptyCell.column,
            row: emptyCell.row
        )
        publishBoardItemState()
        assertBoardItemsMatchStoredCells()
        return true
    }

    // 구매 거래 도중 예상치 못한 저장 실패가 생겼을 때 보드 배치를 되돌리기 위한 함수입니다.
    @discardableResult
    func removePermanentItem(_ kind: BoardItemKind) -> Bool {
        guard (kind.isCookingTool || kind == .jangdokdae),
              let item = boardState.items(of: kind).first else {
            return false
        }

        if selectedItem === item {
            clearSelection()
        }

        boardState.removeItem(at: item.cell)
        item.removeFromParent()
        publishBoardItemState()
        assertBoardItemsMatchStoredCells()
        return true
    }

    private func restorePurchasedPermanentItemsIfPossible() {
        // didMove 이전에는 칸 크기와 boardNode가 준비되지 않았으므로 buildBoard가 나중에 복원합니다.
        guard boardNode.parent != nil, cellSize > 0 else {
            return
        }

        for kind in purchasedPermanentItemKinds where boardState.items(of: kind).isEmpty {
            guard placePermanentItemIfPossible(kind) else {
                continue
            }
        }
    }

    @discardableResult
    private func addBoardItem(
        _ kind: BoardItemKind,
        column: Int,
        row: Int,
        isLocked: Bool = false
    ) -> BoardItemNode {
        let cell = BoardCell(column: column, row: row)

        let item = BoardItemNode(
            kind: kind,
            cell: cell,
            isLocked: isLocked
        )

        item.configureAppearance(cellSize: cellSize)
        item.position = positionForCell(cell)
        item.zPosition = 1

        boardNode.addChild(item)
        boardState.add(item, at: cell)
        return item
    }

    // MARK: - Touch Drag

    // 손가락을 화면에 댄 순간입니다.
    // 터치 위치에 보드 아이템이 있으면, 그 아이템을 이번 드래그의 대상으로 저장합니다.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 머지 연출 중이거나 이미 한 아이템을 드래그 중이라면 추가 터치는 무시합니다.
        guard !isMergeFeedbackRunning,
              activeTouch == nil,
              draggedItem == nil,
              let touch = touches.first else {
            return
        }

        let touchLocation = touch.location(in: self)
        guard let item = boardItemNode(at: touchLocation) else {
            return
        }


        // 잠긴 아이템은 목표물로만 사용하며 직접 선택하거나 드래그할 수 없습니다.
        // 조리 중인 냄비도 연출이 끝날 때까지 탭과 드래그를 받지 않습니다.
        guard !item.isLocked, !item.isCooking else {
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

        // 재료가 들어 있는 냄비는 선택할 수는 있지만 칸 밖으로 끌어낼 수 없습니다.
        guard item.isDraggable else {
            return
        }

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

        // 재료가 들어 있는 냄비는 손가락 이동량과 관계없이 원래 칸에 고정합니다.
        // touchesMoved뿐 아니라 최종 좌표를 반영하는 touchesEnded에서도 막아야 보드 상태가 바뀌지 않습니다.
        guard item.isDraggable else {
            item.position = positionForCell(startCell)
            finishDragging()
            select(item)
            assertBoardItemsMatchStoredCells()
            return
        }

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
        let resolution = resolveDrop(of: item, from: startCell, to: targetCell)
        finishDragging()

        if resolution.shouldPlayMergeFeedback {
            playMergeFeedback(on: resolution.itemToSelect)
        } else {
            // 손가락 드래그 상태를 먼저 종료한 뒤, 이동·스위치 결과 아이템을 선택 상태로 유지합니다.
            select(resolution.itemToSelect)
        }

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
              let emptyCell = boardState.firstEmptyCell() else {
            return
        }

        // 빈 칸을 확인한 뒤 차감하므로 보드가 가득 찬 실패 상황에는 에너지를 사용하지 않습니다.
        // 에너지가 0이거나 SwiftUI와 연결되지 않았다면 생성도 실행하지 않습니다.
        guard consumeEnergyForSpawn?() == true else {
            return
        }

        // 실제 아이템을 먼저 목표 칸에 등록해 연속 탭의 다음 빈 칸 탐색에서 제외합니다.
        // 이동 연출이 끝날 때까지는 숨겨 두고 조작하지 못하게 합니다.
        let spawnedItem = addBoardItem(
            spawnedKind,
            column: emptyCell.column,
            row: emptyCell.row
        )
        spawnedItem.isAwaitingSpawnArrival = true
        spawnedItem.isHidden = true

        playSpawnAnimation(
            from: generator.position,
            to: positionForCell(emptyCell),
            kind: spawnedKind,
            revealing: spawnedItem
        )
    }

    private func playSpawnAnimation(
        from startPosition: CGPoint,
        to targetPosition: CGPoint,
        kind: BoardItemKind,
        revealing spawnedItem: BoardItemNode
    ) {
        // BoardState에 등록하지 않는 화면 연출 전용 노드입니다.
        // BoardItemNode가 아니므로 이동 중에 탭하거나 드래그할 수 없습니다.
        // 실제 보드 아이템과 같은 픽셀 이미지 또는 임시 이모지를 사용합니다.
        let effectNode = BoardItemNode.makeVisualNode(
            for: kind,
            cellSize: cellSize
        )
        effectNode.name = SpawnAnimation.effectNodeName
        effectNode.position = startPosition
        effectNode.zPosition = SpawnAnimation.effectZPosition
        boardNode.addChild(effectNode)

        // 이 함수는 빈 칸을 확보해 실제 스폰 아이템을 등록한 뒤에만 호출됩니다.
        // 따라서 첫 번째 선택 탭, 보드가 가득 찼거나 에너지가 부족한 실패 상황에는 소리가 나지 않습니다.
        gameSoundPlayer.play(.generatorSpawn, on: self)

        let move = SKAction.move(
            to: targetPosition,
            duration: SpawnAnimation.duration
        )
        move.timingMode = .easeOut

        effectNode.run(move) { [weak self, weak effectNode, weak spawnedItem] in
            effectNode?.removeFromParent()

            guard let self,
                  let spawnedItem,
                  spawnedItem.parent === self.boardNode else {
                return
            }

            // 이동용 노드를 제거한 뒤 예약해 둔 실제 아이템을 일반 보드 아이템으로 전환합니다.
            spawnedItem.isAwaitingSpawnArrival = false
            spawnedItem.isHidden = false
            self.publishBoardItemState()
            self.assertBoardItemsMatchStoredCells()
        }
    }

    // MARK: - Grid Snap

    private func resolveDrop(
        of draggedItem: BoardItemNode,
        from startCell: BoardCell,
        to targetCell: BoardCell
    ) -> DropResolution {
        // 시작한 칸에 다시 놓았다면 데이터는 바꾸지 않고 칸 중앙에 정확히 맞춥니다.
        guard targetCell != startCell else {
            draggedItem.position = positionForCell(startCell)
            return DropResolution(
                itemToSelect: draggedItem,
                shouldPlayMergeFeedback: false
            )
        }

        // 목표 칸이 비었다면 BoardState에서 아이템의 칸을 이동합니다.
        // 화면 위치와 보드 상태를 같은 시점에 갱신해야 둘이 어긋나지 않습니다.
        guard let targetItem = boardState.item(at: targetCell) else {
            boardState.move(draggedItem, from: startCell, to: targetCell)
            draggedItem.position = positionForCell(targetCell)
            return DropResolution(
                itemToSelect: draggedItem,
                shouldPlayMergeFeedback: false
            )
        }

        // 화면상 이동 중인 아이템의 목표 칸은 이미 예약된 칸입니다.
        // 도착하기 전에는 머지나 스위치를 실행하지 않고 드래그한 아이템을 원래 칸으로 돌립니다.
        guard !targetItem.isAwaitingSpawnArrival else {
            draggedItem.position = positionForCell(startCell)
            return DropResolution(
                itemToSelect: draggedItem,
                shouldPlayMergeFeedback: false
            )
        }

        // 잠긴 아이템은 일반 머지·조리·위치 교체보다 먼저 판정합니다.
        // 같은 종류·같은 레벨이면 잠금 해제와 머지를 한 번에 처리하고,
        // 조건이 맞지 않으면 두 아이템을 바꾸지 않고 드래그한 아이템만 원래 칸으로 돌립니다.
        if targetItem.isLocked {
            switch LockedItemDropRule.result(
                draggedKind: draggedItem.kind,
                lockedKind: targetItem.kind
            ) {
            case let .merge(nextKind):
                let mergedItem = mergeItems(
                    draggedItem,
                    with: targetItem,
                    from: startCell,
                    at: targetCell,
                    into: nextKind
                )
                return DropResolution(
                    itemToSelect: mergedItem,
                    shouldPlayMergeFeedback: true
                )

            case .reject:
                draggedItem.position = positionForCell(startCell)
                return DropResolution(
                    itemToSelect: draggedItem,
                    shouldPlayMergeFeedback: false
                )
            }
        }

        // 반죽을 열린 빈 냄비에 놓으면 반죽 노드를 제거하고 냄비의 내용물 상태로 옮깁니다.
        // 다른 재료이거나 이미 내용물이 있는 냄비라면 두 아이템을 교체하지 않고 원래 칸으로 돌립니다.
        if targetItem.kind.isCookingTool {
            guard draggedItem.kind == .dough,
                  targetItem.loadCookingIngredient(.dough) else {
                draggedItem.position = positionForCell(startCell)
                return DropResolution(
                    itemToSelect: draggedItem,
                    shouldPlayMergeFeedback: false
                )
            }

            boardState.removeItem(at: startCell)
            draggedItem.removeFromParent()
            publishBoardItemState()
            return DropResolution(
                itemToSelect: targetItem,
                shouldPlayMergeFeedback: false
            )
        }

        // 같은 재료이고 다음 단계가 있다면 두 아이템을 다음 단계 하나로 머지합니다.
        // 단계별 규칙은 BoardItemKind.nextKind가 담당하므로 모든 곡물 단계가 같은 흐름을 사용합니다.
        if draggedItem.kind == targetItem.kind,
           let nextKind = draggedItem.kind.nextKind {
            let mergedItem = mergeItems(
                draggedItem,
                with: targetItem,
                from: startCell,
                at: targetCell,
                into: nextKind
            )

            return DropResolution(
                itemToSelect: mergedItem,
                shouldPlayMergeFeedback: true
            )
        }

        // 다른 종류·다른 단계이거나 다음 단계가 없는 아이템은 서로 위치를 교체합니다.
        swapItems(draggedItem, with: targetItem, from: startCell, to: targetCell)
        return DropResolution(
            itemToSelect: draggedItem,
            shouldPlayMergeFeedback: false
        )
    }

    private func mergeItems(
        _ draggedItem: BoardItemNode,
        with targetItem: BoardItemNode,
        from startCell: BoardCell,
        at targetCell: BoardCell,
        into nextKind: BoardItemKind
    ) -> BoardItemNode {
        // 먼저 BoardState에서 두 칸의 기존 점유 정보를 제거합니다.
        // 화면 노드를 제거한 뒤 상태에 남는 유령 아이템이 없도록 함께 갱신합니다.
        boardState.removeItem(at: startCell)
        boardState.removeItem(at: targetCell)

        draggedItem.removeFromParent()
        targetItem.removeFromParent()

        // 머지 결과는 사용자가 드롭한 목표 칸에 하나만 생성합니다.
        // addBoardItem이 새 노드를 화면과 BoardState에 동시에 등록합니다.
        let mergedItem = addBoardItem(
            nextKind,
            column: targetCell.column,
            row: targetCell.row
        )
        publishBoardItemState()
        return mergedItem
    }

    // MARK: - Order Readiness

    private func publishBoardItemState() {
        var counts: [BoardItemKind: Int] = [:]

        for item in boardState.itemsByCell.values
        where !item.isAwaitingSpawnArrival && !item.isHidden {
            counts[item.kind, default: 0] += 1
        }

        refreshOrderCheckIndicators()
        onBoardItemCountsChanged?(counts)
    }

    private func refreshOrderCheckIndicators() {
        for item in boardState.itemsByCell.values {
            item.showsOrderCheck = activeOrderItemKinds.contains(item.kind)
        }
    }

    // MARK: - Cooking

    // 선택한 냄비에서 조리 전 재료를 빼 첫 번째 빈 칸에 되돌립니다.
    @discardableResult
    func removeIngredientFromSelectedPot() -> Bool {
        guard let pot = selectedItem,
              pot.kind.isCookingTool,
              let emptyCell = boardState.firstEmptyCell(),
              let ingredientKind = pot.removeCookingIngredient() else {
            return false
        }

        addBoardItem(
            ingredientKind,
            column: emptyCell.column,
            row: emptyCell.row
        )
        publishCookingPotSelection()
        publishBoardItemState()
        assertBoardItemsMatchStoredCells()
        return true
    }

    // 선택한 냄비의 반죽을 소비하고, 빈 칸 하나를 수제비 도착 칸으로 먼저 예약한 뒤 조리를 시작합니다.
    @discardableResult
    func cookSelectedPot() -> Bool {
        guard let pot = selectedItem,
              pot.kind.isCookingTool,
              pot.cookingPotState == .loaded(.dough),
              let outputCell = boardState.firstEmptyCell() else {
            return false
        }

        // 조리 도중 생성기 연속 탭으로 빈 칸을 빼앗기지 않도록 완성품을 숨긴 채 BoardState에 먼저 등록합니다.
        let sujebi = addBoardItem(
            .sujebi,
            column: outputCell.column,
            row: outputCell.row
        )
        sujebi.isAwaitingSpawnArrival = true
        sujebi.isHidden = true

        guard pot.beginCooking() else {
            boardState.removeItem(at: outputCell)
            sujebi.removeFromParent()
            return false
        }

        publishCookingPotSelection()
        playCookingAnimation(on: pot, revealing: sujebi)
        return true
    }

    private func playCookingAnimation(
        on pot: BoardItemNode,
        revealing sujebi: BoardItemNode
    ) {
        let potCenter = positionForCell(pot.cell)
        let steam = makeSteamEffect(at: potCenter)
        boardNode.addChild(steam)

        let shakeRight = SKAction.moveBy(
            x: CookingAnimation.shakeDistance,
            y: 0,
            duration: CookingAnimation.shakeStepDuration
        )
        let shakeLeft = SKAction.moveBy(
            x: -CookingAnimation.shakeDistance * 2,
            y: 0,
            duration: CookingAnimation.shakeStepDuration * 2
        )
        let returnCenter = SKAction.move(
            to: potCenter,
            duration: CookingAnimation.shakeStepDuration
        )
        let oneShake = SKAction.sequence([shakeRight, shakeLeft, returnCenter])

        pot.run(.repeat(oneShake, count: CookingAnimation.shakeCount)) {
            [weak self, weak pot, weak sujebi, weak steam] in
            steam?.removeFromParent()

            guard let self,
                  let pot,
                  let sujebi,
                  pot.parent === self.boardNode,
                  sujebi.parent === self.boardNode else {
                return
            }

            pot.position = potCenter
            pot.finishCooking()
            self.publishCookingPotSelection()
            self.playCookedFoodAnimation(from: pot, revealing: sujebi)
        }
    }

    private func playCookedFoodAnimation(
        from pot: BoardItemNode,
        revealing sujebi: BoardItemNode
    ) {
        let effectNode = BoardItemNode.makeVisualNode(for: .sujebi, cellSize: cellSize)
        effectNode.position = pot.position
        effectNode.zPosition = 4
        boardNode.addChild(effectNode)

        let move = SKAction.move(
            to: positionForCell(sujebi.cell),
            duration: CookingAnimation.foodTravelDuration
        )
        move.timingMode = .easeOut
        let pop = SKAction.sequence([
            .scale(to: 1.14, duration: CookingAnimation.foodTravelDuration * 0.55),
            .scale(to: 1, duration: CookingAnimation.foodTravelDuration * 0.45)
        ])

        effectNode.run(.group([move, pop])) {
            [weak self, weak effectNode, weak sujebi] in
            effectNode?.removeFromParent()

            guard let self,
                  let sujebi,
                  sujebi.parent === self.boardNode else {
                return
            }

            sujebi.isAwaitingSpawnArrival = false
            sujebi.isHidden = false
            self.publishBoardItemState()
            self.assertBoardItemsMatchStoredCells()
        }
    }

    private func makeSteamEffect(at potCenter: CGPoint) -> SKNode {
        let steam = SKNode()
        steam.position = CGPoint(x: potCenter.x, y: potCenter.y + cellSize * 0.38)
        steam.zPosition = 4

        for horizontalOffset: CGFloat in [-0.14, 0, 0.14] {
            let puff = SKShapeNode(circleOfRadius: cellSize * 0.07)
            puff.fillColor = .white.withAlphaComponent(0.78)
            puff.strokeColor = .clear
            puff.position.x = cellSize * horizontalOffset
            puff.run(.repeatForever(.sequence([
                .moveBy(x: 0, y: cellSize * 0.16, duration: 0.35),
                .moveBy(x: 0, y: -cellSize * 0.16, duration: 0)
            ])))
            steam.addChild(puff)
        }

        return steam
    }

    // MARK: - Order Delivery

    // SwiftUI의 완료 버튼이 호출하더라도 실제 납품 가능 여부는 SpriteKit 보드 상태로 다시 확인합니다.
    // 성공하면 노드를 보드에서 소비하고, 주문 카드 이동 연출에 사용할 종류와 출발 좌표를 반환합니다.
    func consumeItemsForOrder(
        _ requirement: OrderItemRequirement
    ) -> [BoardDeliveryItem]? {
        guard requirement.quantity > 0 else {
            return nil
        }

        let availableItems = boardState.items(of: requirement.itemKind)
            .filter { !$0.isAwaitingSpawnArrival && !$0.isHidden }

        guard availableItems.count >= requirement.quantity else {
            return nil
        }

        // BoardState가 위쪽 행·왼쪽 열 순서로 정렬했으므로 필요한 수량만 앞에서 선택합니다.
        let itemsToDeliver = Array(availableItems.prefix(requirement.quantity))
        let deliveryItems = itemsToDeliver.map {
            BoardDeliveryItem(kind: $0.kind, scenePosition: $0.position)
        }

        if let selectedItem,
           itemsToDeliver.contains(where: { $0 === selectedItem }) {
            clearSelection()
        }

        // 화면 노드와 칸 점유 상태를 같은 흐름에서 제거해 유령 아이템이 남지 않게 합니다.
        for item in itemsToDeliver {
            boardState.removeItem(at: item.cell)
            item.removeFromParent()
        }

        publishBoardItemState()
        assertBoardItemsMatchStoredCells()
        return deliveryItems
    }

    private func swapItems(
        _ draggedItem: BoardItemNode,
        with targetItem: BoardItemNode,
        from startCell: BoardCell,
        to targetCell: BoardCell
    ) {
        // BoardState의 두 칸을 교체한 뒤 두 화면 노드도 각 칸 중앙에 배치합니다.
        boardState.swap(
            draggedItem,
            at: startCell,
            with: targetItem,
            at: targetCell
        )
        targetItem.position = positionForCell(startCell)
        draggedItem.position = positionForCell(targetCell)
    }

    // MARK: - Merge Feedback

    private func playMergeFeedback(on item: BoardItemNode) {
        isMergeFeedbackRunning = true
        clearSelection()

        // 새 결과 아이템이 나타나는 팝 연출 시작점에 음계와 햅틱도 함께 실행합니다.
        mergeFeedbackPlayer.play(for: item.kind, on: self)

        // 결과 아이템은 작게 시작해 살짝 크게 튄 뒤 원래 크기로 돌아옵니다.
        // 수치는 MergeAnimation에 모아 두어 플레이테스트 후 한곳에서 조정할 수 있습니다.
        item.setScale(MergeAnimation.initialScale)

        let grow = SKAction.scale(
            to: MergeAnimation.peakScale,
            duration: MergeAnimation.growDuration
        )
        grow.timingMode = .easeOut

        let settle = SKAction.scale(
            to: 1,
            duration: MergeAnimation.settleDuration
        )
        settle.timingMode = .easeInEaseOut

        item.run(.sequence([grow, settle])) { [weak self, weak item] in
            guard let self else {
                return
            }

            self.isMergeFeedbackRunning = false

            guard let item, item.parent === self.boardNode else {
                return
            }

            // 액션의 최종 크기를 보정한 뒤에만 선택 꼭짓점을 표시합니다.
            item.setScale(1)
            self.select(item)
            self.assertBoardItemsMatchStoredCells()
        }
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
        // 화면 노드로 등록된 보드 아이템과 BoardState에 저장된 아이템의 개수가 같은지 확인합니다.
        // 이동 연출용 SKLabelNode는 BoardItemNode가 아니므로 이 검사에서 제외됩니다.
        let boardItems = boardNode.children.compactMap { $0 as? BoardItemNode }
        assert(
            boardItems.count == boardState.itemCount,
            "화면 노드의 아이템 개수와 BoardState에 저장된 아이템 개수가 다릅니다."
        )

        // 각 보드 아이템이 자신의 cell 주소로 BoardState에도 등록되어 있는지 확인합니다.
        for item in boardItems {
            guard let storedItem = boardState.item(at: item.cell) else {
                assertionFailure("화면에는 아이템이 있지만 해당 칸이 BoardState에 저장되어 있지 않습니다.")
                continue
            }

            assert(
                storedItem === item,
                "화면의 아이템과 BoardState에 저장된 아이템이 서로 다른 객체입니다."
            )
        }

        // BoardState의 칸 주소, 아이템이 기억하는 cell, 실제 화면 존재 여부가 모두 같은지 확인합니다.
        for (cell, item) in boardState.itemsByCell {
            assert(boardState.contains(cell), "보드 범위를 벗어난 칸에 아이템이 저장되었습니다.")
            assert(item.cell == cell, "BoardState의 칸과 아이템이 기억하는 칸이 다릅니다.")
            assert(item.parent === boardNode, "BoardState에는 아이템이 있지만 화면에는 존재하지 않습니다.")
        }

        assert(boardState.itemCount <= columns * rows, "보드의 전체 칸 수보다 많은 아이템이 저장되었습니다.")

        if let selectedItem {
            assert(selectedItem.parent === boardNode, "선택된 아이템이 화면에 존재하지 않습니다.")
        }
#endif
    }

    // MARK: - Selection

    private func select(_ item: BoardItemNode) {
        clearSelection()
        selectedItem = item
        item.isSelected = true
        publishCookingPotSelection()
    }

    private func clearSelection() {
        selectedItem?.isSelected = false
        selectedItem = nil
        publishCookingPotSelection()
    }

    private func publishCookingPotSelection() {
        guard let selectedItem,
              selectedItem.kind.isCookingTool else {
            onCookingPotSelectionChanged?(nil)
            return
        }

        switch selectedItem.cookingPotState {
        case .empty:
            onCookingPotSelectionChanged?(nil)
        case let .loaded(ingredientKind):
            onCookingPotSelectionChanged?(.loaded(ingredientKind))
        case .cooking:
            onCookingPotSelectionChanged?(.cooking)
        }
    }

    private func boardItemNode(at position: CGPoint) -> BoardItemNode? {
        // 같은 위치의 모든 노드를 확인해 위를 지나가는 스폰 연출 노드는 건너뜁니다.
        // 선택 테두리는 아이템의 자식 노드이므로 각 노드에서 부모 방향으로도 탐색합니다.
        for hitNode in nodes(at: position) {
            var node: SKNode? = hitNode

            while let currentNode = node {
                if let item = currentNode as? BoardItemNode,
                   item.name == "boardItem",
                   !item.isAwaitingSpawnArrival {
                    return item
                }

                node = currentNode.parent
            }
        }

        return nil
    }

    private func constrainedPosition(
        for item: SKNode,
        proposedPosition: CGPoint
    ) -> CGPoint {
        let boardBounds = CGRect(
            x: boardOrigin.x,
            y: boardOrigin.y,
            width: cellSize * CGFloat(columns),
            height: cellSize * CGFloat(rows)
        )

        // 아이템 노드의 실제 크기를 사용해, 픽셀 이미지가 반쯤 잘려 나가지 않게 제한합니다.
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
