//
//  generate_merge_sounds.swift
//  Merge
//
//  머지 결과 단계에 사용할 짧은 픽셀 벨 음원을 생성합니다.
//

import Foundation

private struct Note {
    let fileName: String
    let frequency: Double
}

private enum SoundSettings {
    static let sampleRate = 44_100
    static let duration = 0.18
    static let maximumAmplitude = 0.68
    static let attackDuration = 0.002
    static let releaseDuration = 0.012
}

private let notes = [
    Note(fileName: "merge_do.wav", frequency: 523.25),
    Note(fileName: "merge_re.wav", frequency: 587.33),
    Note(fileName: "merge_mi.wav", frequency: 659.25),
    Note(fileName: "merge_fa.wav", frequency: 698.46)
]

private func makeSamples(frequency: Double) -> [Int16] {
    let sampleCount = Int(SoundSettings.duration * Double(SoundSettings.sampleRate))
    var rawSamples = [Double]()
    rawSamples.reserveCapacity(sampleCount)

    for sampleIndex in 0..<sampleCount {
        let time = Double(sampleIndex) / Double(SoundSettings.sampleRate)
        let remainingTime = SoundSettings.duration - time

        // 매우 짧게 소리가 커졌다가 자연스럽게 줄어드는 타격음 형태입니다.
        let attack = min(time / SoundSettings.attackDuration, 1)
        let release = min(max(remainingTime / SoundSettings.releaseDuration, 0), 1)

        // 따뜻한 기본음과 빠르게 사라지는 비정수 배음으로 나무 마림바 몸통을 만듭니다.
        let woodenFundamental = 0.78
            * sin(2 * .pi * frequency * time)
            * exp(-18 * time)
        let woodenOvertone = 0.15
            * sin(2 * .pi * frequency * 3.95 * time)
            * exp(-38 * time)
        let woodenTap = 0.07
            * sin(2 * .pi * frequency * 9.10 * time)
            * exp(-54 * time)
        let woodenMarimba = woodenFundamental + woodenOvertone + woodenTap

        // 시작 순간에만 짧게 남는 삼각파를 10% 섞어 픽셀 게임 특유의 클릭감을 더합니다.
        let pixelPhase = 2 * .pi * frequency * 2 * time
        let pixelTriangle = (2 / .pi) * asin(sin(pixelPhase))
        let pixelClick = pixelTriangle * exp(-72 * time)
        let mixedTimbre = (woodenMarimba * 0.90) + (pixelClick * 0.10)

        let sample = mixedTimbre
            * attack
            * release
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
        Data("Usage: swift generate_merge_sounds.swift <output-directory>\n".utf8)
    )
    exit(EXIT_FAILURE)
}

let outputDirectory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(
    at: outputDirectory,
    withIntermediateDirectories: true
)

for note in notes {
    let samples = makeSamples(frequency: note.frequency)
    let destination = outputDirectory.appendingPathComponent(note.fileName)
    try makeWAVData(samples: samples).write(to: destination, options: .atomic)
    print("Created \(destination.path)")
}
