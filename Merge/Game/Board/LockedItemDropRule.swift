//
//  LockedItemDropRule.swift
//  Merge
//
//  잠긴 아이템 위에 드롭했을 때의 결과를 결정합니다.
//

enum LockedItemDropResult: Equatable {
    case merge(into: BoardItemKind)
    case reject
}

enum LockedItemDropRule {
    static func result(
        draggedKind: BoardItemKind,
        lockedKind: BoardItemKind
    ) -> LockedItemDropResult {
        // 같은 종류·같은 레벨이고 다음 단계가 있을 때만 잠금 해제와 머지를 함께 실행합니다.
        // 다른 아이템이거나 최고 단계라면 위치 교체 없이 드래그한 아이템을 돌려보냅니다.
        guard draggedKind == lockedKind,
              let nextKind = draggedKind.nextKind else {
            return .reject
        }

        return .merge(into: nextKind)
    }
}
