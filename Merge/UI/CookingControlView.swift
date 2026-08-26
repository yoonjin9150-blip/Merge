//
//  CookingControlView.swift
//  Merge
//
//  선택한 냄비의 재료 확인과 조리 시작 버튼을 표시합니다.
//

import SwiftUI

struct CookingControlView: View {
    let state: CookingPotSelectionState
    let onRemoveIngredient: () -> Void
    let onCook: () -> Void

    private let outlineColor = Color(
        red: 0.08,
        green: 0.07,
        blue: 0.20
    )

    var body: some View {
        HStack(spacing: 10) {
            Image("CookingPotOpenPixel")
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 48, height: 48)

            switch state {
            case let .loaded(ingredientKind):
                VStack(alignment: .leading, spacing: 2) {
                    Text("냄비에 재료가 들어 있어요")
                        .font(.system(size: 12, weight: .black, design: .rounded))

                    HStack(spacing: 4) {
                        Image(ingredientKind.textureName)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 24, height: 24)

                        Text("반죽 ×1")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                    }
                }
                .foregroundStyle(outlineColor)

                Spacer(minLength: 0)

                Button("재료 빼기", action: onRemoveIngredient)
                    .buttonStyle(PixelCookingButtonStyle(isPrimary: false))

                Button("요리하기", action: onCook)
                    .buttonStyle(PixelCookingButtonStyle(isPrimary: true))

            case .cooking:
                Text("수제비 조리 중…")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(outlineColor)

                Spacer()

                ProgressView()
                    .tint(outlineColor)
            }
        }
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity)
        .frame(height: 68)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 1, green: 0.92, blue: 0.64))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(outlineColor, lineWidth: 3)
                }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 4)
    }
}

private struct PixelCookingButtonStyle: ButtonStyle {
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .black, design: .rounded))
            .foregroundStyle(
                isPrimary
                    ? Color.white
                    : Color(red: 0.08, green: 0.07, blue: 0.20)
            )
            .padding(.horizontal, 9)
            .frame(height: 34)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isPrimary
                            ? Color(red: 0.95, green: 0.36, blue: 0.32)
                            : Color.white.opacity(0.72)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                Color(red: 0.08, green: 0.07, blue: 0.20),
                                lineWidth: 2
                            )
                    }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

