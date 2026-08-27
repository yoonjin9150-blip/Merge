//
//  ShopView.swift
//  Merge
//
//  코인으로 영구 조리도구와 생성기를 구매하는 상점 화면입니다.
//

import SwiftUI

struct ShopView: View {
    let coins: Int
    let purchasedProducts: Set<ShopProduct>
    let canPlaceProduct: (ShopProduct) -> Bool
    let onPurchase: (ShopProduct) -> Bool

    @Environment(\.dismiss) private var dismiss

    private let outlineColor = Color(red: 0.08, green: 0.07, blue: 0.20)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.68, green: 0.86, blue: 0.98)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        Text("새로운 도구와 생성기를 준비해 보세요!")
                            .font(.system(size: 17, weight: .black, design: .rounded))
                            .foregroundStyle(outlineColor)

                        ForEach(ShopProduct.allCases) { product in
                            productCard(product)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
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

    private func productCard(_ product: ShopProduct) -> some View {
        VStack(spacing: 10) {
            Image(product.boardItemKind.textureName)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 112, height: 112)

            Text(product.title)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)

            Text(product.description)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(outlineColor.opacity(0.72))
                .multilineTextAlignment(.center)

            purchaseButton(for: product)
        }
        .padding(20)
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
    }

    private func purchaseButton(for product: ShopProduct) -> some View {
        let isPurchased = purchasedProducts.contains(product)
        let canPlace = canPlaceProduct(product)
        let canPurchase = !isPurchased && coins >= product.price && canPlace

        return Button {
            _ = onPurchase(product)
        } label: {
            HStack(spacing: 7) {
                if !isPurchased {
                    PixelCoinIcon()
                }

                Text(
                    purchaseButtonTitle(
                        for: product,
                        isPurchased: isPurchased,
                        canPlace: canPlace
                    )
                )
                .font(.system(size: 16, weight: .black, design: .rounded))
            }
            .foregroundStyle(canPurchase ? Color.white : outlineColor.opacity(0.48))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        canPurchase
                            ? Color(red: 0.96, green: 0.43, blue: 0.42)
                            : outlineColor.opacity(0.10)
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(!canPurchase)
        .accessibilityHint(
            purchaseAccessibilityHint(
                for: product,
                isPurchased: isPurchased,
                canPlace: canPlace
            )
        )
    }

    private func purchaseButtonTitle(
        for product: ShopProduct,
        isPurchased: Bool,
        canPlace: Bool
    ) -> String {
        if isPurchased {
            return "구매 완료"
        }

        if coins < product.price {
            return "코인 부족 · \(product.price)"
        }

        if !canPlace {
            return "보드 공간 부족"
        }

        return "\(product.price)코인으로 구매"
    }

    private func purchaseAccessibilityHint(
        for product: ShopProduct,
        isPurchased: Bool,
        canPlace: Bool
    ) -> String {
        if isPurchased {
            return "이미 영구 구매한 상품입니다."
        }

        if coins < product.price {
            return "주문을 완료해 코인을 더 모아야 합니다."
        }

        if !canPlace {
            return "머지 보드에 빈 칸이 필요합니다."
        }

        return "두 번 탭하면 \(product.title)을 구매해 보드에 배치합니다."
    }
}

#Preview {
    ShopView(
        coins: 40,
        purchasedProducts: [.cookingPot],
        canPlaceProduct: { _ in true },
        onPurchase: { _ in true }
    )
}
