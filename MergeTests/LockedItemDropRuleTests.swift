//
//  LockedItemDropRuleTests.swift
//  MergeTests
//
//  잠긴 아이템의 드롭 판정 규칙을 검증합니다.
//

import Testing
@testable import Merge

struct LockedItemDropRuleTests {
    @Test
    func 같은단계밀을잠긴밀에놓으면밀가루로머지한다() {
        let result = LockedItemDropRule.result(
            draggedKind: .wheat,
            lockedKind: .wheat
        )

        #expect(result == .merge(into: .flour))
    }

    @Test
    func 다른종류나단계아이템은잠금해제를거절한다() {
        let result = LockedItemDropRule.result(
            draggedKind: .flour,
            lockedKind: .wheat
        )

        #expect(result == .reject)
    }

    @Test
    func 다음단계가없는최고레벨아이템은잠금해제를거절한다() {
        let result = LockedItemDropRule.result(
            draggedKind: .riceCake,
            lockedKind: .riceCake
        )

        #expect(result == .reject)
    }
}
