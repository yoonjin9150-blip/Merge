//
//  ShopView.swift
//  Merge
//
//  코인으로 영구 조리도구를 구매하는 상점 화면입니다.
//

import SwiftUI

struct ShopView: View {
    let coins: Int
    let isCookingPotPurchased: Bool
    let canPlaceCookingPot: Bool
    let onPurchaseCookingPot: () -> Bool

    @Environment(\.dismiss) private var dismiss

    private let product = ShopProduct.cookingPot
    private let outlineColor = Color(red: 0.08, green: 0.07, blue: 0.20)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.68, green: 0.86, blue: 0.98)
                    .ignoresSafeArea()

                VStack(spacing: 18) {
                    Text("새로운 조리도구를 준비해 보세요!")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundStyle(outlineColor)

                    VStack(spacing: 12) {
                        Image(product.boardItemKind.textureName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 136, height: 136)

                        Text(product.title)
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(outlineColor)

                        Text("구매하면 머지 보드의 첫 번째 빈 칸에 놓이며\n사라지지 않고 계속 사용할 수 있어요.")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(outlineColor.opacity(0.72))
                            .multilineTextAlignment(.center)

                        purchaseButton
                    }
                    .padding(22)
                    .frame(maxWidth: 310)
                    .background {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color(red: 1, green: 0.97, blue: 0.85))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(outlineColor, lineWidth: 4)
                            }
                            .shadow(
                                color: outlineColor.opacity(0.28),
                                radius: 0,
                                x: 5,
                                y: 6
                            )
                    }

                    Spacer(minLength: 0)
                }
                .padding(.top, 20)
                .padding(.horizontal, 24)
            }
            .navigationTitle("상점")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }

    private var purchaseButton: some View {
        Button {
            _ = onPurchaseCookingPot()
        } label: {
            HStack(spacing: 7) {
                if !isCookingPotPurchased {
                    PixelCoinIcon()
                }

                Text(purchaseButtonTitle)
                    .font(.system(size: 16, weight: .black, design: .rounded))
            }
            .foregroundStyle(purchaseButtonForegroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(purchaseButtonBackgroundColor)
            }
        }
        .buttonStyle(.plain)
        .disabled(!canPurchaseCookingPot)
        .accessibilityHint(purchaseAccessibilityHint)
    }

    private var canPurchaseCookingPot: Bool {
        !isCookingPotPurchased
            && coins >= product.price
            && canPlaceCookingPot
    }

    private var purchaseButtonTitle: String {
        if isCookingPotPurchased {
            return "구매 완료"
        }

        if coins < product.price {
            return "코인 부족 · \(product.price)"
        }

        if !canPlaceCookingPot {
            return "보드 공간 부족"
        }

        return "\(product.price)코인으로 구매"
    }

    private var purchaseButtonForegroundColor: Color {
        canPurchaseCookingPot ? .white : outlineColor.opacity(0.48)
    }

    private var purchaseButtonBackgroundColor: Color {
        canPurchaseCookingPot
            ? Color(red: 0.96, green: 0.43, blue: 0.42)
            : outlineColor.opacity(0.10)
    }

    private var purchaseAccessibilityHint: String {
        if isCookingPotPurchased {
            return "이미 영구 구매한 조리도구입니다."
        }

        if coins < product.price {
            return "주문을 완료해 코인을 더 모아야 합니다."
        }

        if !canPlaceCookingPot {
            return "머지 보드에 빈 칸이 필요합니다."
        }

        return "두 번 탭하면 냄비를 구매해 보드에 배치합니다."
    }
}

#Preview {
    ShopView(
        coins: 8,
        isCookingPotPurchased: false,
        canPlaceCookingPot: true,
        onPurchaseCookingPot: { true }
    )
}
