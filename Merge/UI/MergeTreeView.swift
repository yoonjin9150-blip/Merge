//
//  MergeTreeView.swift
//  Merge
//
//  선택한 아이템의 머지 순서와 출처 생성기를 한눈에 보여 줍니다.
//

import SwiftUI

struct MergeTreeView: View {
    @Environment(\.dismiss) private var dismiss

    let selectedKind: BoardItemKind

    private let itemsPerRow = 4
    private let outlineColor = Color(
        red: 0.08,
        green: 0.07,
        blue: 0.20
    )

    private var treeKinds: [BoardItemKind] {
        selectedKind.mergeTreeKinds
    }

    private var treeRows: [[BoardItemKind]] {
        stride(from: 0, to: treeKinds.count, by: itemsPerRow).map { start in
            let end = min(start + itemsPerRow, treeKinds.count)
            return Array(treeKinds[start..<end])
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    if treeKinds.isEmpty {
                        emptyTreeView
                    } else {
                        Text("총 \(treeKinds.count)단계")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                            .foregroundStyle(outlineColor)

                        treeGrid

                        if let generatorKind = selectedKind.mergeTreeGeneratorKind {
                            sourceSection(generatorKind)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 22)
            }
            .background(Color(red: 1, green: 0.97, blue: 0.91))
            .navigationTitle("\(selectedKind.mergeTreeTitle ?? selectedKind.displayName) 머지 트리")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .black))
                    }
                    .accessibilityLabel("머지 트리 닫기")
                }
            }
        }
    }

    private var treeGrid: some View {
        VStack(spacing: 14) {
            ForEach(Array(treeRows.enumerated()), id: \.offset) { rowIndex, row in
                HStack(spacing: 5) {
                    ForEach(Array(row.enumerated()), id: \.element.rawValue) { itemIndex, kind in
                        if itemIndex > 0 {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .black))
                                .foregroundStyle(outlineColor.opacity(0.48))
                                .frame(width: 10)
                        }

                        MergeTreeItemCell(
                            stage: (rowIndex * itemsPerRow) + itemIndex + 1,
                            kind: kind,
                            isSelected: kind == selectedKind
                        )
                    }

                    Spacer(minLength: 0)
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.72))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(outlineColor.opacity(0.16), lineWidth: 2)
                }
        }
    }

    private func sourceSection(_ generatorKind: BoardItemKind) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 9) {
                Rectangle()
                    .fill(outlineColor.opacity(0.18))
                    .frame(height: 2)

                Text("이 트리의 생성기")
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(outlineColor)
                    .fixedSize()

                Rectangle()
                    .fill(outlineColor.opacity(0.18))
                    .frame(height: 2)
            }

            HStack(spacing: 12) {
                Image(generatorKind.textureName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 3) {
                    Text(generatorKind.displayName)
                        .font(.system(size: 15, weight: .black, design: .rounded))

                    Text(generatorSourceDescription(for: generatorKind))
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(outlineColor.opacity(0.68))
                }

                Spacer()

                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(Color(red: 0.98, green: 0.65, blue: 0.12))
            }
            .foregroundStyle(outlineColor)
            .padding(.horizontal, 14)
            .frame(height: 78)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(red: 0.78, green: 0.94, blue: 0.98))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(outlineColor, lineWidth: 3)
                    }
            }
        }
    }

    private func generatorSourceDescription(for generatorKind: BoardItemKind) -> String {
        let generatedKinds = generatorKind.generatorSpawnOptions.map(\.kind)

        guard !generatedKinds.isEmpty else {
            return "탭하면 재료가 나와요"
        }

        return "탭하면 \(generatedKinds.map(\.displayName).joined(separator: " 또는 "))이 나와요"
    }

    private var emptyTreeView: some View {
        VStack(spacing: 12) {
            Image(selectedKind.textureNameForIdleCookingTool)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: 88, height: 88)

            Text(selectedKind.displayName)
                .font(.system(size: 18, weight: .black, design: .rounded))

            Text("이 아이템은 머지 단계가 없어요")
                .font(.system(size: 13, weight: .bold, design: .rounded))
        }
        .foregroundStyle(outlineColor)
        .padding(24)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.72))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(outlineColor, lineWidth: 3)
                }
        }
    }
}

private struct MergeTreeItemCell: View {
    let stage: Int
    let kind: BoardItemKind
    let isSelected: Bool

    private let outlineColor = Color(
        red: 0.08,
        green: 0.07,
        blue: 0.20
    )

    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.84, green: 0.94, blue: 0.91))

                Image(kind.textureName)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .padding(7)

                Text("\(stage)")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background {
                        Circle()
                            .fill(Color(red: 0.10, green: 0.73, blue: 0.83))
                    }
                    .offset(x: -4, y: -4)
            }
            .frame(width: 60, height: 60)
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected
                            ? Color(red: 0.06, green: 0.80, blue: 0.84)
                            : Color.clear,
                        lineWidth: 4
                    )
            }

            Text(kind.displayName)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(outlineColor)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(width: 60)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(stage)단계 \(kind.displayName)\(isSelected ? ", 선택됨" : "")")
    }
}
