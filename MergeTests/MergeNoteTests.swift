//
//  MergeNoteTests.swift
//  MergeTests
//
//  머지 결과 단계와 도·레·미·파 음원의 연결 규칙을 검증합니다.
//

import Testing
@testable import Merge

@MainActor
struct MergeNoteTests {

    @Test
    func 머지결과단계는도레미파순서로연결된다() {
        #expect(MergeNote.note(for: .flour) == .doNote)
        #expect(MergeNote.note(for: .dough) == .reNote)
        #expect(MergeNote.note(for: .noodle) == .miNote)
        #expect(MergeNote.note(for: .riceCake) == .faNote)
        #expect(MergeNote.note(for: .chiliPowder) == .doNote)
        #expect(MergeNote.note(for: .gochujang) == .reNote)
        #expect(MergeNote.note(for: .seasoningSauce) == .miNote)
    }

    @Test
    func 머지결과가아닌아이템에는음계가없다() {
        #expect(MergeNote.note(for: .grainSack) == nil)
        #expect(MergeNote.note(for: .cookingPot) == nil)
        #expect(MergeNote.note(for: .fryingPan) == nil)
        #expect(MergeNote.note(for: .wheat) == nil)
        #expect(MergeNote.note(for: .jangdokdae) == nil)
        #expect(MergeNote.note(for: .chiliPepper) == nil)
    }

    @Test
    func 각음계는서로다른음원파일을사용한다() {
        let fileNames = Set([
            MergeNote.doNote.soundFileName,
            MergeNote.reNote.soundFileName,
            MergeNote.miNote.soundFileName,
            MergeNote.faNote.soundFileName
        ])

        #expect(fileNames.count == 4)
    }
}
