//
//  generate_spawn_sound.swift
//  Merge
//
//  생성기에서 아이템이 출발할 때 사용할 짧은 푝 효과음을 생성합니다.
//

import Foundation

private enum SoundSettings {
    static let sampleRate = 44_100
    static let duration = 0.10
    static let maximumAmplitude = 0.44
    static let attackDuration = 0.0015
    static let releaseDuration = 0.010
    static let startFrequency = 980.0
    static let endFrequency = 410.0
}

private func makeSamples() -> [Int16] {
    let sampleCount = Int(SoundSettings.duration * Double(SoundSettings.sampleRate))
    let frequencySlope = (
        SoundSettings.endFrequency - SoundSettings.startFrequency
    ) / SoundSettings.duration
    var randomState: UInt64 = 0x5EED
    var filteredNoise = 0.0
    var rawSamples = [Double]()
    rawSamples.reserveCapacity(sampleCount)

    for sampleIndex in 0..<sampleCount {
        let time = Double(sampleIndex) / Double(SoundSettings.sampleRate)
        let remainingTime = SoundSettings.duration - time
        let attack = min(time / SoundSettings.attackDuration, 1)
        let release = min(max(remainingTime / SoundSettings.releaseDuration, 0), 1)

        // 주파수가 빠르게 내려가는 짧은 사인파가 말랑한 공기방울 몸통을 만듭니다.
        let phase = 2 * .pi * (
            (SoundSettings.startFrequency * time)
                + (0.5 * frequencySlope * time * time)
        )
        let bubbleBody = sin(phase) * exp(-28 * time)
        let softOvertone = sin(phase * 1.72) * exp(-52 * time)

        // 고정된 난수 시드를 사용해 실행할 때마다 같은 짧은 공기 마찰음을 만듭니다.
        randomState = randomState &* 6_364_136_223_846_793_005 &+ 1
        let randomUnit = Double((randomState >> 33) & 0x7FFF_FFFF)
            / Double(0x7FFF_FFFF)
        let whiteNoise = (randomUnit * 2) - 1
        filteredNoise = (filteredNoise * 0.58) + (whiteNoise * 0.42)
        let airClick = filteredNoise * exp(-90 * time)

        let sample = (
            (bubbleBody * 0.82)
                + (softOvertone * 0.10)
                + (airClick * 0.08)
        ) * attack * release
        rawSamples.append(sample)
    }

    let peak = rawSamples.map(abs).max() ?? 1
    let scale = peak > 0 ? SoundSettings.maximumAmplitude / peak : 1

    return rawSamples.map { sample in
        Int16((sample * scale * Double(Int16.max)).rounded())
    }
}

private func appendASCII(_ value: String, to data: inout Data) {
    data.append(contentsOf: value.utf8)
}

private func appendLittleEndian<T: FixedWidthInteger>(_ value: T, to data: inout Data) {
    var littleEndianValue = value.littleEndian
    Swift.withUnsafeBytes(of: &littleEndianValue) { bytes in
        data.append(contentsOf: bytes)
    }
}

private func makeWAVData(samples: [Int16]) -> Data {
    let channelCount: UInt16 = 1
    let bitsPerSample: UInt16 = 16
    let bytesPerSample = UInt32(bitsPerSample / 8)
    let dataSize = UInt32(samples.count) * bytesPerSample
    let byteRate = UInt32(SoundSettings.sampleRate) * UInt32(channelCount) * bytesPerSample
    let blockAlign = channelCount * (bitsPerSample / 8)

    var data = Data()
    appendASCII("RIFF", to: &data)
    appendLittleEndian(UInt32(36) + dataSize, to: &data)
    appendASCII("WAVE", to: &data)
    appendASCII("fmt ", to: &data)
    appendLittleEndian(UInt32(16), to: &data)
    appendLittleEndian(UInt16(1), to: &data)
    appendLittleEndian(channelCount, to: &data)
    appendLittleEndian(UInt32(SoundSettings.sampleRate), to: &data)
    appendLittleEndian(byteRate, to: &data)
    appendLittleEndian(blockAlign, to: &data)
    appendLittleEndian(bitsPerSample, to: &data)
    appendASCII("data", to: &data)
    appendLittleEndian(dataSize, to: &data)

    for sample in samples {
        appendLittleEndian(sample, to: &data)
    }

    return data
}

guard CommandLine.arguments.count == 2 else {
    FileHandle.standardError.write(
        Data("Usage: swift generate_spawn_sound.swift <output-directory>\n".utf8)
    )
    exit(EXIT_FAILURE)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(
    at: outputDirectory,
    withIntermediateDirectories: true
)

let destination = outputDirectory.appendingPathComponent("generator_spawn_pop.wav")
try makeWAVData(samples: makeSamples()).write(to: destination, options: .atomic)
print("Created \(destination.path)")
