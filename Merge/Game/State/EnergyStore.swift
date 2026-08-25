//
//  EnergyStore.swift
//  Merge
//
//  에너지 상태를 SwiftUI와 SpriteKit이 함께 사용하고 기기에 저장합니다.
//

import Combine
import Foundation

final class EnergyStore: ObservableObject {
    @Published private(set) var currentEnergy: Int
    @Published private(set) var secondsUntilNextRecovery: Int?

    let maximumEnergy = EnergyState.maximumEnergy

    private enum StorageKey {
        static let currentEnergy = "energy.current"
        static let recoveryAnchorTimestamp = "energy.recoveryAnchorTimestamp"
    }

    private var state: EnergyState
    private let defaults: UserDefaults

    init(
        defaults: UserDefaults = .standard,
        now: Date = Date()
    ) {
        self.defaults = defaults

        let storedEnergy = defaults.object(
            forKey: StorageKey.currentEnergy
        ) as? Int
        let storedTimestamp = defaults.object(
            forKey: StorageKey.recoveryAnchorTimestamp
        ) as? TimeInterval

        var restoredState = EnergyState(
            currentEnergy: storedEnergy ?? EnergyState.initialEnergy,
            recoveryAnchorDate: storedTimestamp.map(Date.init(timeIntervalSince1970:)) ?? now
        )
        restoredState.recover(at: now)

        state = restoredState
        currentEnergy = restoredState.currentEnergy
        secondsUntilNextRecovery = restoredState.secondsUntilNextRecovery(at: now)
        save()
    }

    // 화면의 초 단위 표시와 앱 복귀 시 경과 시간 회복을 함께 갱신합니다.
    func refresh(at date: Date = Date()) {
        let previousState = state
        state.recover(at: date)
        publish(at: date)

        if state != previousState {
            save()
        }
    }

    // SpriteKit이 빈 칸을 확인한 뒤 호출합니다. 성공한 경우에만 에너지가 1 감소합니다.
    @discardableResult
    func consumeForSuccessfulSpawn(at date: Date = Date()) -> Bool {
        guard state.consumeForSuccessfulSpawn(at: date) else {
            publish(at: date)
            return false
        }

        publish(at: date)
        save()
        return true
    }

    private func publish(at date: Date) {
        currentEnergy = state.currentEnergy
        secondsUntilNextRecovery = state.secondsUntilNextRecovery(at: date)
    }

    private func save() {
        defaults.set(
            state.currentEnergy,
            forKey: StorageKey.currentEnergy
        )
        defaults.set(
            state.recoveryAnchorDate.timeIntervalSince1970,
            forKey: StorageKey.recoveryAnchorTimestamp
        )
    }
}
