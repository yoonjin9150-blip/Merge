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

    // 베이킹 찬장을 해금하고 디저트 재료 트리를 시작하는 단계입니다.
    case openBakery = 3

    static func < (lhs: GameChapter, rhs: GameChapter) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    var shortBadge: String {
        "CH.\(rawValue)"
    }

    var title: String {
        switch self {
        case .relightStove:
            return "화구 되살리기"
        case .restoreJangFlavor:
            return "장맛 되찾기"
        case .openBakery:
            return "베이킹 준비하기"
        }
    }

    var storyDescription: String {
        switch self {
        case .relightStove:
            return "먼지 쌓인 부엌에서 오래도록 꺼져 있던 화구를 발견했어요."
        case .restoreJangFlavor:
            return "가게를 대표하던 장맛이 사라져 예전의 떡볶이를 만들 수 없어요."
        case .openBakery:
            return "비어 있던 찬장에서 달콤한 재료의 흔적을 발견했어요."
        }
    }

    // 챕터 진행과 직접 연결되는 핵심 주문입니다.
    // 아직 완료 조건이 정해지지 않은 마지막 챕터에는 스토리 주문을 지정하지 않습니다.
    var storyOrderTemplateID: String? {
        switch self {
        case .relightStove:
            return GameOrderTemplate.cooking(.sujebi).templateID
        case .restoreJangFlavor:
            return GameOrderTemplate.cooking(.tteokbokki).templateID
        case .openBakery:
            return nil
        }
    }

    // 플레이어가 다음 챕터로 넘어가기 위해 지금 해야 하는 행동입니다.
    // 아직 다음 챕터 규칙이 정해지지 않은 마지막 챕터에서는 nil입니다.
    var nextChapterRequirement: String? {
        switch self {
        case .relightStove:
            return "수제비 첫 주문을 완료하세요."
        case .restoreJangFlavor:
            return "떡볶이 첫 주문을 완료하세요."
        case .openBakery:
            return nil
        }
    }

    var nextChapterReward: String? {
        switch self {
        case .relightStove:
            return "CH.2 · 장독대와 후라이팬 해금"
        case .restoreJangFlavor:
            return "CH.3 · 베이킹 찬장 해금"
        case .openBakery:
            return nil
        }
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

    // 각 챕터의 대표 음식 첫 납품을 완료 조건으로 사용합니다.
    // 이미 다음 챕터라면 이전 조건이 중복 호출되어도 진행 상태를 다시 변경하지 않습니다.
    @discardableResult
    func recordCompletedOrder(_ order: GameOrder) -> Bool {
        switch currentChapter {
        case .relightStove:
            guard order.templateID == GameOrderTemplate.cooking(.sujebi).templateID else {
                return false
            }
            currentChapter = .restoreJangFlavor
        case .restoreJangFlavor:
            guard order.templateID == GameOrderTemplate.cooking(.tteokbokki).templateID else {
                return false
            }
            currentChapter = .openBakery
        case .openBakery:
            return false
        }

        save()
        return true
    }

    private func save() {
        defaults.set(currentChapter.rawValue, forKey: StorageKey.currentChapter)
    }
}
