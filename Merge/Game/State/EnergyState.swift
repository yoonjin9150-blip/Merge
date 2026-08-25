//
//  EnergyState.swift
//  Merge
//
//  에너지 소모와 경과 시간 기반 회복 규칙을 계산합니다.
//

import Foundation

struct EnergyState: Equatable {
    static let maximumEnergy = 100
    static let initialEnergy = 100

    // 밸런스 테스트 후 이 값만 바꾸면 회복 주기를 조정할 수 있습니다.
    static let recoveryInterval: TimeInterval = 30

    private(set) var currentEnergy: Int
    private(set) var recoveryAnchorDate: Date

    var isFull: Bool {
        currentEnergy == Self.maximumEnergy
    }

    init(
        currentEnergy: Int = Self.initialEnergy,
        recoveryAnchorDate: Date
    ) {
        self.currentEnergy = min(
            max(currentEnergy, 0),
            Self.maximumEnergy
        )
        self.recoveryAnchorDate = recoveryAnchorDate
    }

    // 앱이 켜져 있는지와 관계없이 마지막 기준 시각부터 지난 시간으로 회복량을 계산합니다.
    mutating func recover(at date: Date) {
        guard !isFull else {
            return
        }

        let elapsedTime = date.timeIntervalSince(recoveryAnchorDate)

        // 사용자가 기기 시각을 과거로 바꾸더라도 음수 시간만큼 회복이 멈추지 않게 기준을 다시 잡습니다.
        guard elapsedTime >= 0 else {
            recoveryAnchorDate = date
            return
        }

        let recoveredEnergy = Int(elapsedTime / Self.recoveryInterval)
        guard recoveredEnergy > 0 else {
            return
        }

        currentEnergy = min(
            currentEnergy + recoveredEnergy,
            Self.maximumEnergy
        )

        if isFull {
            // 완충 이후의 남은 시간은 미리 저장하지 않습니다.
            recoveryAnchorDate = date
        } else {
            // 30초 미만의 남은 시간은 다음 회복 계산에 이어서 사용합니다.
            recoveryAnchorDate = recoveryAnchorDate.addingTimeInterval(
                Double(recoveredEnergy) * Self.recoveryInterval
            )
        }
    }

    // 생성 성공 직전에 호출합니다. 에너지가 없으면 false를 반환하고 값을 바꾸지 않습니다.
    mutating func consumeForSuccessfulSpawn(at date: Date) -> Bool {
        recover(at: date)

        guard currentEnergy > 0 else {
            return false
        }

        let wasFull = isFull
        currentEnergy -= 1

        // 완충 상태에서 처음 에너지를 사용한 순간부터 새로운 30초 회복을 시작합니다.
        if wasFull {
            recoveryAnchorDate = date
        }

        return true
    }

    // 완충 상태에서는 nil을 반환하여 UI가 회복 시간을 숨기게 합니다.
    func secondsUntilNextRecovery(at date: Date) -> Int? {
        guard !isFull else {
            return nil
        }

        let elapsedTime = max(
            date.timeIntervalSince(recoveryAnchorDate),
            0
        )
        let elapsedInCurrentInterval = elapsedTime
            .truncatingRemainder(dividingBy: Self.recoveryInterval)
        let remainingTime = Self.recoveryInterval - elapsedInCurrentInterval

        return max(Int(ceil(remainingTime)), 1)
    }
}
