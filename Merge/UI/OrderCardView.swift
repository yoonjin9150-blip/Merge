//
//  OrderCardView.swift
//  Merge
//
//  활성 주문의 필요 아이템, 준비 상태, 코인 보상을 표시합니다.
//

import SwiftUI

struct OrderCardView: View {
    let order: GameOrder
    let itemCounts: [BoardItemKind: Int]
    let onComplete: () -> Void

    init(order: GameOrder) {
        self.order = order
        itemCounts = [:]
        onComplete = {}
    }

    init(
        order: GameOrder,
        itemCounts: [BoardItemKind: Int],
        onComplete: @escaping () -> Void
    ) {
        self.order = order
        self.itemCounts = itemCounts
        self.onComplete = onComplete
    }

    private let outlineColor = Color(
        red: 0.08,
        green: 0.07,
        blue: 0.20
    )

    private var isReady: Bool {
        order.isReady(in: itemCounts)
    }

    var body: some View {
        VStack(spacing: 5) {
            HStack(alignment: .top, spacing: 5) {
                requestedItem

                Spacer(minLength: 0)

                reward
            }

            if !order.recipeIngredients.isEmpty {
                recipeIngredients
            }

            Button("완료", action: onComplete)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(isReady ? Color.white : outlineColor.opacity(0.45))
                .frame(maxWidth: .infinity)
                .frame(height: 24)
                .background {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            isReady
                                ? Color(red: 0.20, green: 0.72, blue: 0.36)
                                : outlineColor.opacity(0.10)
                        )
                }
                .disabled(!isReady)
        }
        .padding(8)
        .frame(width: 120, height: 110)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 1, green: 0.97, blue: 0.85))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isReady
                                ? Color(red: 0.20, green: 0.72, blue: 0.36)
                                : outlineColor,
                            lineWidth: 3
                        )
                }
                .shadow(
                    color: outlineColor.opacity(0.28),
                    radius: 0,
                    x: 3,
                    y: 4
                )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(order.title)
        .accessibilityValue(
            isReady
                ? "납품 준비 완료, 보상 \(order.coinReward)코인"
                : "납품 아이템 부족, 보상 \(order.coinReward)코인"
        )
    }

    private var requestedItem: some View {
        VStack(spacing: 1) {
            OrderItemImage(
                requirement: order.requestedItem,
                availableQuantity: itemCounts[
                    order.requestedItem.itemKind,
                    default: 0
                ],
                sideLength: 48
            )

            Text(order.title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    private var recipeIngredients: some View {
        HStack(spacing: 2) {
            ForEach(
                Array(order.recipeIngredients.enumerated()),
                id: \.offset
            ) { index, ingredient in
                if index > 0 {
                    Text("+")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundStyle(outlineColor)
                }

                OrderItemImage(
                    requirement: ingredient,
                    availableQuantity: itemCounts[ingredient.itemKind, default: 0],
                    sideLength: 28
                )
            }
        }
    }

    private var reward: some View {
        HStack(spacing: 2) {
            PixelCoinIcon()

            Text("\(order.coinReward)")
                .font(.system(size: 14, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)
                .monospacedDigit()
        }
    }
}

private struct OrderItemImage: View {
    let requirement: OrderItemRequirement
    let availableQuantity: Int
    let sideLength: CGFloat

    private var isPrepared: Bool {
        availableQuantity >= requirement.quantity
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(requirement.itemKind.textureName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: sideLength, height: sideLength)

            Text("×\(requirement.quantity)")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(Color(red: 0.08, green: 0.07, blue: 0.20))
                .padding(.horizontal, 2)
                .background(Color(red: 1, green: 0.97, blue: 0.85).opacity(0.9))

            if isPrepared {
                PixelPreparedCheck()
                    .offset(x: 3, y: 3)
            }
        }
        .frame(width: sideLength, height: sideLength)
    }
}

private struct PixelPreparedCheck: View {
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(Color.white)
            .frame(width: 16, height: 16)
            .background(Color(red: 0.20, green: 0.72, blue: 0.36))
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.white, lineWidth: 1.5)
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
    HStack {
        OrderCardView(
            order: .flourDelivery,
            itemCounts: [:],
            onComplete: {}
        )

        OrderCardView(
            order: .flourDelivery,
            itemCounts: [.flour: 1],
            onComplete: {}
        )
    }
    .padding()
    .background(Color(red: 0.68, green: 0.86, blue: 0.98))
}
