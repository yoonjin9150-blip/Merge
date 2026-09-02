//
//  BoardItemInformationTests.swift
//  MergeTests
//
//  선택 정보와 머지 트리가 게임 규칙의 단계 순서를 그대로 사용하는지 검증합니다.
//

import Testing
@testable import Merge

struct BoardItemInformationTests {

    @Test
    func 곡물생성기와재료는같은전체트리를공유한다() {
        let expected: [BoardItemKind] = [
            .wheat,
            .flour,
            .dough,
            .noodle,
            .riceCake
        ]

        #expect(BoardItemKind.grainSack.mergeTreeKinds == expected)
        #expect(BoardItemKind.flour.mergeTreeKinds == expected)
        #expect(BoardItemKind.riceCake.mergeTreeKinds == expected)
        #expect(BoardItemKind.flour.mergeTreeTitle == "곡물 재료")
        #expect(BoardItemKind.flour.mergeTreeGeneratorKind == .grainSack)
    }

    @Test
    func 베이킹찬장은일곱단계재료트리를보여준다() {
        #expect(
            BoardItemKind.bakingCabinet.mergeTreeKinds == [
                .sugar,
                .egg,
                .milk,
                .butter,
                .whippedCream,
                .cheese,
                .chocolate
            ]
        )
        #expect(BoardItemKind.bakingCabinet.mergeTreeTitle == "베이킹 재료")
        #expect(BoardItemKind.chocolate.mergeTreeGeneratorKind == .bakingCabinet)
    }

    @Test
    func 조리도구와완성음식은머지단계가없다() {
        #expect(BoardItemKind.cookingPot.mergeTreeKinds.isEmpty)
        #expect(BoardItemKind.sujebi.mergeTreeKinds.isEmpty)
        #expect(BoardItemKind.cookingPot.mergeTreeTitle == nil)
        #expect(BoardItemKind.cookingPot.mergeTreeGeneratorKind == nil)
    }

    @Test
    func 선택정보는다음단계와최고단계를구분한다() {
        #expect(BoardItemKind.flour.informationDescription.contains("반죽"))
        #expect(BoardItemKind.riceCake.informationDescription.contains("최고 단계"))
        #expect(BoardItemKind.grainSack.informationDescription == "탭하면 밀을 만드는 생성기예요.")
        #expect(BoardItemKind.jangdokdae.informationDescription == "탭하면 고추를 만드는 생성기예요.")
        #expect(
            BoardItemKind.bakingCabinet.informationDescription
                == "탭하면 설탕 또는 달걀을 만드는 생성기예요."
        )
    }

    @Test
    func 판매가는단계별로오르고영구아이템은판매할수없다() {
        #expect(BoardItemKind.wheat.salePrice == 1)
        #expect(BoardItemKind.dough.salePrice == 1)
        #expect(BoardItemKind.noodle.salePrice == 2)
        #expect(BoardItemKind.riceCake.salePrice == 2)
        #expect(BoardItemKind.cheese.salePrice == 4)
        #expect(BoardItemKind.chocolate.salePrice == 6)
        #expect(BoardItemKind.sujebi.salePrice == 3)
        #expect(BoardItemKind.grainSack.salePrice == nil)
        #expect(BoardItemKind.cookingPot.salePrice == nil)
    }
}
