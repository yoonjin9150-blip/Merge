//
//  GameSoundPlayer.swift
//  Merge
//
//  게임에서 사용하는 짧은 효과음을 SpriteKit 노드에서 재생합니다.
//

import SpriteKit

enum GameSoundEffect: Equatable {
    case merge(MergeNote)
    case generatorSpawn
    case brickBreak

    var soundFileName: String {
        switch self {
        case .merge(let note):
            return note.soundFileName
        case .generatorSpawn:
            return "generator_spawn_pop.wav"
        case .brickBreak:
            return "brick_break.wav"
        }
    }
}

@MainActor
struct GameSoundPlayer {

    func play(_ effect: GameSoundEffect, on node: SKNode) {
        // false이면 앞의 효과음이 끝날 때까지 기다리지 않아 연속 입력의 소리가 겹칠 수 있습니다.
        let soundAction = SKAction.playSoundFileNamed(
            effect.soundFileName,
            waitForCompletion: false
        )
        node.run(soundAction)
    }
}
