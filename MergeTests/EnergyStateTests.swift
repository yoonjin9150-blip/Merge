//
//  EnergyStateTests.swift
//  MergeTests
//
//  에너지 소모, 시간 회복, 기기 저장 규칙을 검증합니다.
//

import Foundation
import Testing
@testable import Merge

@MainActor
struct EnergyStateTests {
    private let startDate = Date(timeIntervalSince1970: 1_800_000_000)

    @Test
    func 최초에너지는100이고완충상태에는회복시간이없다() {
        let state = EnergyState(recoveryAnchorDate: startDate)

        #expect(state.currentEnergy == 100)
        #expect(state.isFull)
        #expect(state.secondsUntilNextRecovery(at: startDate) == nil)
    }

    @Test
    func 생성성공비용은1이고에너지가0이면소모할수없다() {
        var availableState = EnergyState(
            currentEnergy: 1,
            recoveryAnchorDate: startDate
        )
        var emptyState = EnergyState(
            currentEnergy: 0,
            recoveryAnchorDate: startDate
        )

        let didConsumeAvailableEnergy = availableState
            .consumeForSuccessfulSpawn(at: startDate)
        let didConsumeEmptyEnergy = emptyState
            .consumeForSuccessfulSpawn(at: startDate)

        #expect(didConsumeAvailableEnergy)
        #expect(availableState.currentEnergy == 0)
        #expect(!didConsumeEmptyEnergy)
        #expect(emptyState.currentEnergy == 0)
    }

    @Test
    func 경과한30초마다에너지가1씩회복된다() {
        var state = EnergyState(
            currentEnergy: 90,
            recoveryAnchorDate: startDate
        )

        state.recover(at: startDate.addingTimeInterval(90))

        #expect(state.currentEnergy == 93)
        #expect(
            state.recoveryAnchorDate
                == startDate.addingTimeInterval(90)
        )
    }

    @Test
    func 앱종료중오래지나도에너지는100을초과하지않는다() {
        var state = EnergyState(
            currentEnergy: 97,
            recoveryAnchorDate: startDate
        )
        let returnDate = startDate.addingTimeInterval(600)

        state.recover(at: returnDate)

        #expect(state.currentEnergy == 100)
        #expect(state.recoveryAnchorDate == returnDate)
        #expect(state.secondsUntilNextRecovery(at: returnDate) == nil)
    }

    @Test
    func 남은회복시간은에너지를추가로사용해도초기화되지않는다() {
        var state = EnergyState(
            currentEnergy: 90,
            recoveryAnchorDate: startDate
        )
        let fortySevenSecondsLater = startDate.addingTimeInterval(47)

        state.recover(at: fortySevenSecondsLater)
        #expect(state.currentEnergy == 91)
        #expect(
            state.secondsUntilNextRecovery(at: fortySevenSecondsLater) == 13
        )

        let didConsume = state.consumeForSuccessfulSpawn(
            at: fortySevenSecondsLater
        )

        #expect(didConsume)
        #expect(state.currentEnergy == 90)
        #expect(
            state.secondsUntilNextRecovery(at: fortySevenSecondsLater) == 13
        )
    }

    @Test
    func 완충상태에서처음사용한순간부터30초회복이시작된다() {
        var state = EnergyState(recoveryAnchorDate: startDate)
        let useDate = startDate.addingTimeInterval(300)

        let didConsume = state.consumeForSuccessfulSpawn(at: useDate)

        #expect(didConsume)
        #expect(state.currentEnergy == 99)
        #expect(state.recoveryAnchorDate == useDate)
        #expect(state.secondsUntilNextRecovery(at: useDate) == 30)
    }

    @Test
    func 저장된에너지와종료중경과시간을다음실행에서복원한다() {
        let suiteName = "EnergyStateTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let firstLaunchStore = EnergyStore(
            defaults: defaults,
            now: startDate
        )
        #expect(firstLaunchStore.consumeForSuccessfulSpawn(at: startDate))
        #expect(firstLaunchStore.consumeForSuccessfulSpawn(at: startDate))
        #expect(firstLaunchStore.currentEnergy == 98)

        let relaunchedStore = EnergyStore(
            defaults: defaults,
            now: startDate.addingTimeInterval(30)
        )

        #expect(relaunchedStore.currentEnergy == 99)
        #expect(relaunchedStore.secondsUntilNextRecovery == 30)
    }
}
