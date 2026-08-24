//
//  GameSoundEffectTests.swift
//  MergeTests
//
//  게임 효과음의 파일 매핑과 앱 번들 포함 여부를 검증합니다.
//

import Foundation
import Testing
@testable import Merge

@MainActor
struct GameSoundEffectTests {

    @Test
    func 생성기스폰은전용푝음원을사용한다() {
        #expect(
            GameSoundEffect.generatorSpawn.soundFileName
                == "generator_spawn_pop.wav"
        )
    }

    @Test
    func 머지음계와스폰효과음은앱번들에포함된다() {
        let effects: [GameSoundEffect] = [
            .merge(.doNote),
            .merge(.reNote),
            .merge(.miNote),
            .merge(.faNote),
            .generatorSpawn
        ]

        for effect in effects {
            let resourceURL = Bundle.main.url(
                forResource: effect.soundFileName,
                withExtension: nil
            )
            #expect(resourceURL != nil)
        }
    }
}
