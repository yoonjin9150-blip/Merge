//
//  OrderCardView.swift
//  Merge
//
//  활성 주문의 필요 아이템과 코인 보상을 표시합니다.
//

import SwiftUI

struct OrderCardView: View {
    let order: GameOrder

    private let outlineColor = Color(
        red: 0.08,
        green: 0.07,
        blue: 0.20
    )

    var body: some View {
        HStack(spacing: 10) {
            orderLabel
            requiredItem
            Spacer(minLength: 4)
            reward
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 72)
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
        .accessibilityLabel(order.title)
        .accessibilityValue(
            "필요 아이템 \(order.requiredQuantity)개, 보상 \(order.coinReward)코인"
        )
    }

    private var orderLabel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("주문")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(Color.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color(red: 0.26, green: 0.60, blue: 0.91))
                }

            Text(order.title)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)
                .lineLimit(1)
        }
        .frame(width: 96, alignment: .leading)
    }

    private var requiredItem: some View {
        HStack(spacing: 3) {
            Image(order.requiredItemKind.textureName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 48, height: 48)

            Text("×\(order.requiredQuantity)")
                .font(.system(size: 17, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)
                .monospacedDigit()
        }
    }

    private var reward: some View {
        VStack(spacing: 2) {
            Text("보상")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(outlineColor.opacity(0.65))

            HStack(spacing: 4) {
                PixelCoinIcon()

                Text("\(order.coinReward)")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(outlineColor)
                    .monospacedDigit()
            }
        }
    }
}

private struct PixelCoinIcon: View {
    private let coinColor = Color(red: 1, green: 0.78, blue: 0.10)
    private let highlightColor = Color(red: 1, green: 0.94, blue: 0.42)
    private let shadowColor = Color(red: 0.91, green: 0.42, blue: 0.08)

    var body: some View {
        ZStack {
            coinPath
                .fill(shadowColor)
                .offset(x: 2, y: 2)

            coinPath
                .fill(coinColor)

            Rectangle()
                .fill(highlightColor)
                .frame(width: 5, height: 9)
                .offset(x: -4, y: -3)
        }
        .frame(width: 27, height: 27)
    }

    private var coinPath: Path {
        Path { path in
            path.move(to: CGPoint(x: 7, y: 1))
            path.addLine(to: CGPoint(x: 20, y: 1))
            path.addLine(to: CGPoint(x: 26, y: 7))
            path.addLine(to: CGPoint(x: 26, y: 20))
            path.addLine(to: CGPoint(x: 20, y: 26))
            path.addLine(to: CGPoint(x: 7, y: 26))
            path.addLine(to: CGPoint(x: 1, y: 20))
            path.addLine(to: CGPoint(x: 1, y: 7))
            path.closeSubpath()
        }
    }
}

#Preview {
    OrderCardView(order: .flourDelivery)
        .padding()
        .background(Color(red: 0.68, green: 0.86, blue: 0.98))
}
