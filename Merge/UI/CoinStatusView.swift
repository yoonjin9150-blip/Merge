//
//  CoinStatusView.swift
//  Merge
//
//  주문 완료로 획득한 현재 코인을 표시합니다.
//

import SwiftUI

struct CoinStatusView: View {
    let coins: Int

    private let outlineColor = Color(red: 0.08, green: 0.07, blue: 0.20)

    var body: some View {
        HStack(spacing: 7) {
            PixelCoinIcon()

            Text("\(coins)")
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)
                .monospacedDigit()
                .frame(minWidth: 44)
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
        .accessibilityLabel("코인")
        .accessibilityValue("\(coins)")
    }
}

struct PixelCoinIcon: View {
    private let coinColor = Color(red: 1, green: 0.78, blue: 0.10)
    private let highlightColor = Color(red: 1, green: 0.94, blue: 0.42)
    private let shadowColor = Color(red: 0.91, green: 0.42, blue: 0.08)

    var body: some View {
        ZStack {
            coinPath
                .fill(shadowColor)
                .offset(x: 1, y: 1)

            coinPath
                .fill(coinColor)

            Rectangle()
                .fill(highlightColor)
                .frame(width: 3, height: 6)
                .offset(x: -3, y: -2)
        }
        .frame(width: 20, height: 20)
    }

    private var coinPath: Path {
        Path { path in
            path.move(to: CGPoint(x: 5, y: 1))
            path.addLine(to: CGPoint(x: 15, y: 1))
            path.addLine(to: CGPoint(x: 19, y: 5))
            path.addLine(to: CGPoint(x: 19, y: 15))
            path.addLine(to: CGPoint(x: 15, y: 19))
            path.addLine(to: CGPoint(x: 5, y: 19))
            path.addLine(to: CGPoint(x: 1, y: 15))
            path.addLine(to: CGPoint(x: 1, y: 5))
            path.closeSubpath()
        }
    }
}

#Preview {
    CoinStatusView(coins: 42)
        .padding()
        .background(Color(red: 0.68, green: 0.86, blue: 0.98))
}
