//
//  MergeFeedbackPlayer.swift
//  Merge
//
//  머지 결과 단계에 맞는 음계와 soft 햅틱을 함께 재생합니다.
//

import SpriteKit
import UIKit

enum MergeNote: Equatable {
    case doNote
    case reNote
    case miNote
    case faNote

    var soundFileName: String {
        switch self {
        case .doNote:
            return "merge_do.wav"
        case .reNote:
            return "merge_re.wav"
        case .miNote:
            return "merge_mi.wav"
        case .faNote:
            return "merge_fa.wav"
        }
    }

    // 머지 횟수가 아니라 새로 만들어진 결과 아이템의 단계를 음계에 연결합니다.
    static func note(for resultKind: BoardItemKind) -> MergeNote? {
        switch resultKind {
        case .flour:
            return .doNote
        case .dough:
            return .reNote
        case .noodle:
            return .miNote
        case .riceCake:
            return .faNote
        case .grainSack, .cookingPot, .wheat, .sujebi:
            return nil
        }
    }
}

@MainActor
final class MergeFeedbackPlayer {

    private let hapticGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let soundPlayer = GameSoundPlayer()

    func prepare() {
        // 다음 머지의 햅틱 지연을 줄이기 위해 미리 준비합니다.
        hapticGenerator.prepare()
    }

    func play(for resultKind: BoardItemKind, on node: SKNode) {
        // 같은 머지 성공 시점에서 햅틱과 음원 재생을 연달아 요청합니다.
        // 서로 다른 시스템이지만 시간 차이가 작아 플레이어에게 동시에 느껴집니다.
        hapticGenerator.impactOccurred()
        hapticGenerator.prepare()

        guard let note = MergeNote.note(for: resultKind) else {
            return
        }

        soundPlayer.play(.merge(note), on: node)
    }
}
