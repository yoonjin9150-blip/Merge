//
//  EnergyStatusView.swift
//  Merge
//
//  현재 에너지와 다음 에너지 회복까지 남은 시간을 표시합니다.
//

import SwiftUI

struct EnergyStatusView: View {
    let currentEnergy: Int
    let maximumEnergy: Int
    let secondsUntilNextRecovery: Int?

    private let outlineColor = Color(
        red: 0.08,
        green: 0.07,
        blue: 0.20
    )

    var body: some View {
        HStack(spacing: 7) {
            PixelEnergyBolt()

            VStack(spacing: 0) {
                Text("\(currentEnergy)")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundStyle(outlineColor)
                    .monospacedDigit()

                if currentEnergy < maximumEnergy,
                   let secondsUntilNextRecovery {
                    Text(formattedTime(secondsUntilNextRecovery))
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            Color(red: 0.91, green: 0.38, blue: 0.18)
                        )
                        .monospacedDigit()
                }
            }
            .frame(width: 58)
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 1, green: 0.97, blue: 0.85))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(outlineColor, lineWidth: 3)
                }
                .shadow(
                    color: outlineColor.opacity(0.28),
                    radius: 0,
                    x: 3,
                    y: 4
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("에너지")
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        if let secondsUntilNextRecovery,
           currentEnergy < maximumEnergy {
            return "\(currentEnergy), 다음 회복까지 \(secondsUntilNextRecovery)초"
        }

        return "\(currentEnergy)"
    }

    private func formattedTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(
            format: "%02d:%02d",
            minutes,
            remainingSeconds
        )
    }
}

private struct PixelEnergyBolt: View {
    private let boltColor = Color(red: 1, green: 0.77, blue: 0.08)
    private let shadowColor = Color(red: 0.91, green: 0.34, blue: 0.10)

    var body: some View {
        ZStack {
            boltPath
                .fill(shadowColor)
                .offset(x: 2, y: 3)

            boltPath
                .fill(boltColor)
        }
        .frame(width: 27, height: 34)
    }

    private var boltPath: Path {
        Path { path in
            path.move(to: CGPoint(x: 16, y: 0))
            path.addLine(to: CGPoint(x: 4, y: 19))
            path.addLine(to: CGPoint(x: 12, y: 19))
            path.addLine(to: CGPoint(x: 9, y: 34))
            path.addLine(to: CGPoint(x: 25, y: 12))
            path.addLine(to: CGPoint(x: 17, y: 12))
            path.closeSubpath()
        }
    }
}

#Preview("완충") {
    EnergyStatusView(
        currentEnergy: 100,
        maximumEnergy: 100,
        secondsUntilNextRecovery: nil
    )
    .padding()
    .background(Color(red: 0.68, green: 0.86, blue: 0.98))
}

#Preview("회복 중") {
    EnergyStatusView(
        currentEnergy: 73,
        maximumEnergy: 100,
        secondsUntilNextRecovery: 18
    )
    .padding()
    .background(Color(red: 0.68, green: 0.86, blue: 0.98))
}
