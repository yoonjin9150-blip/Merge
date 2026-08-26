//
//  BackgroundMusicPlayer.swift
//  Merge
//
//  메인 게임 배경음악을 반복 재생하고 앱 생명주기에 맞춰 일시정지합니다.
//

import AVFoundation
import Combine
import Foundation
import OSLog

enum BackgroundMusicTrack {
    case mainGame

    var soundFileName: String {
        switch self {
        case .mainGame:
            return "bgm.wav"
        }
    }

    // AVAudioPlayer에서 -1은 사용자가 멈출 때까지 계속 반복한다는 뜻입니다.
    var numberOfLoops: Int {
        -1
    }

    // 머지 음계와 생성기 효과음이 배경음악에 묻히지 않도록 낮은 기본 음량을 사용합니다.
    var volume: Float {
        0.22
    }
}

@MainActor
final class BackgroundMusicPlayer: ObservableObject {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Merge",
        category: "BackgroundMusic"
    )
    private var audioPlayer: AVAudioPlayer?

    func play(_ track: BackgroundMusicTrack = .mainGame) {
        if audioPlayer == nil {
            preparePlayer(for: track)
        }

        audioPlayer?.play()
    }

    // pause는 현재 재생 위치를 기억하므로 앱 복귀 시 같은 지점부터 이어집니다.
    func pause() {
        audioPlayer?.pause()
    }

    private func preparePlayer(for track: BackgroundMusicTrack) {
        guard let soundURL = Bundle.main.url(
            forResource: track.soundFileName,
            withExtension: nil
        ) else {
            logger.error("배경음악 파일을 앱 번들에서 찾을 수 없습니다: \(track.soundFileName, privacy: .public)")
            return
        }

        do {
            // ambient는 기기의 무음 모드를 존중하며 다른 앱의 오디오를 강제로 끊지 않습니다.
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.ambient, mode: .default)
            try audioSession.setActive(true)

            let player = try AVAudioPlayer(contentsOf: soundURL)
            player.numberOfLoops = track.numberOfLoops
            player.volume = track.volume
            player.prepareToPlay()
            audioPlayer = player
        } catch {
            // 음악 재생 실패는 핵심 게임 진행을 막지 않도록 기록만 남기고 종료하지 않습니다.
            logger.error("배경음악 재생 준비에 실패했습니다: \(error.localizedDescription, privacy: .public)")
        }
    }
}
