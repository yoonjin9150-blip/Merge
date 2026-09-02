//
//  SelectedItemInfoView.swift
//  Merge
//
//  선택한 보드 아이템의 이름과 간단한 설명, 머지 트리 진입 버튼을 표시합니다.
//

import SwiftUI

struct SelectedItemInfoView: View {
    let kind: BoardItemKind
    let onShowMergeTree: () -> Void
    let onSell: () -> Void

    private let outlineColor = Color(
        red: 0.08,
        green: 0.07,
        blue: 0.20
    )

    var body: some View {
        HStack(spacing: 9) {
            Image(kind.textureNameForIdleCookingTool)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(kind.informationTitle)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    Button(action: onShowMergeTree) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(Color(red: 0.18, green: 0.55, blue: 0.93))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(kind.displayName) 머지 트리 보기")
                }

                Text(kind.informationDescription)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.88)
            }
            .foregroundStyle(outlineColor)
            .frame(maxWidth: .infinity, alignment: .leading)

            if let salePrice = kind.salePrice {
                Button(action: onSell) {
                    VStack(spacing: 2) {
                        Text("판매")
                            .font(.system(size: 10, weight: .black, design: .rounded))

                        HStack(spacing: 2) {
                            PixelCoinIcon()
                                .scaleEffect(0.72)
                                .frame(width: 16, height: 16)

                            Text("+\(salePrice)")
                                .font(.system(size: 14, weight: .black, design: .rounded))
                        }
                    }
                    .foregroundStyle(outlineColor)
                    .frame(width: 54, height: 52)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.41, green: 0.82, blue: 0.96))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(outlineColor, lineWidth: 2)
                            }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(kind.displayName) 판매, \(salePrice)코인 받기")
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
