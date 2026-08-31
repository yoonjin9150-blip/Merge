//
//  GameProgressStore.swift
//  Merge
//
//  가게 성장 챕터와 콘텐츠 해금 진행을 저장하고 복원합니다.
//

import Combine
import Foundation

enum GameChapter: Int, Comparable {
    // 첫 주문으로 냄비를 마련하고 수제비를 만들어 화구를 되살리는 단계입니다.
    case relightStove = 1

    // 장독대를 해금하고 양념 머지 트리를 시작하는 단계입니다.
    case restoreJangFlavor = 2

    static func < (lhs: GameChapter, rhs: GameChapter) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var shortBadge: String {
        "CH.\(rawValue)"
    }
}

@MainActor
final class GameProgressStore: ObservableObject {
    @Published private(set) var currentChapter: GameChapter

    private enum StorageKey {
        static let currentChapter = "game.progress.currentChapter"
    }

    private let defaults: UserDefaults

    init(
        initialChapter: GameChapter? = nil,
        defaults: UserDefaults = .standard
    ) {
        self.defaults = defaults

        if let initialChapter {
            currentChapter = initialChapter
        } else if let restoredChapter = GameChapter(
            rawValue: defaults.integer(forKey: StorageKey.currentChapter)
        ) {
            currentChapter = restoredChapter
        } else {
            currentChapter = .relightStove
        }

        save()
    }

    // 첫 수제비 납품은 챕터 1의 완료 조건입니다.
    // 이미 다음 챕터라면 중복 호출되어도 상태를 다시 저장하거나 보상을 반복하지 않습니다.
    @discardableResult
    func recordCompletedOrder(_ order: GameOrder) -> Bool {
        guard currentChapter == .relightStove,
              order.templateID == GameOrderTemplate.cooking(.sujebi).templateID else {
            return false
        }

        currentChapter = .restoreJangFlavor
        save()
        return true
    }

    private func save() {
        defaults.set(currentChapter.rawValue, forKey: StorageKey.currentChapter)
    }
}
