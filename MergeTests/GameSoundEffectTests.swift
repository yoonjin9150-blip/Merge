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
    func 벽돌파괴는전용효과음을사용한다() {
        #expect(GameSoundEffect.brickBreak.soundFileName == "brick_break.wav")
    }

    @Test
    func 머지음계와스폰효과음은앱번들에포함된다() {
        let effects: [GameSoundEffect] = [
            .merge(.doNote),
            .merge(.reNote),
            .merge(.miNote),
            .merge(.faNote),
            .generatorSpawn,
            .brickBreak
        ]

        for effect in effects {
            let resourceURL = Bundle.main.url(
                forResource: effect.soundFileName,
                withExtension: nil
            )
            #expect(resourceURL != nil)
        }
    }

    @Test
    func 메인배경음악은낮은음량으로무한반복된다() {
        let track = BackgroundMusicTrack.mainGame

        #expect(track.soundFileName == "bgm.wav")
        #expect(track.numberOfLoops == -1)
        #expect(track.volume == 0.22)
        #expect(
            Bundle.main.url(
                forResource: track.soundFileName,
                withExtension: nil
            ) != nil
        )
    }
}
