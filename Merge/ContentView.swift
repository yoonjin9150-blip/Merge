//
//  ContentView.swift
//  Merge
//
//  Created by 이윤진 on 8/16/26.
//

import SpriteKit
import SwiftUI

struct ContentView: View {
    // SpriteKit 게임판입니다. 화면 크기에 맞춰 장면의 크기도 바뀝니다.
    private let boardScene: MergeBoardScene = {
        let scene = MergeBoardScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        ZStack {
            // 상단·SpriteKit·하단 영역 뒤로 하나의 픽셀 하늘 배경이 이어집니다.
            PixelSkyBackground()

            VStack(spacing: 0) {
                // 나중에 프로필·에너지·코인·주문 칸이 들어갈 상단 영역입니다.
                // 현재는 머지 보드 위치를 확인하기 위해 빈 여백으로 둡니다.
                Color.clear
                    .frame(height: 170)

                // SpriteKit 장면을 투명하게 표시해 뒤의 픽셀 하늘이 그대로 보이게 합니다.
                SpriteView(
                    scene: boardScene,
                    options: [.allowsTransparency]
                )

                // 나중에 안내 문구가 들어갈 하단 영역입니다.
                Color.clear
                    .frame(height: 76)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct PixelSkyBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.68, green: 0.86, blue: 0.98)

                PixelSparkle(pixelSize: 4)
                    .position(x: geometry.size.width * 0.14, y: geometry.size.height * 0.12)
                PixelSparkle(pixelSize: 3)
                    .position(x: geometry.size.width * 0.80, y: geometry.size.height * 0.18)
                PixelSparkle(pixelSize: 4)
                    .position(x: geometry.size.width * 0.18, y: geometry.size.height * 0.82)
                PixelSparkle(pixelSize: 3)
                    .position(x: geometry.size.width * 0.84, y: geometry.size.height * 0.74)

                PixelSquare(size: 6)
                    .position(x: geometry.size.width * 0.32, y: geometry.size.height * 0.09)
                PixelSquare(size: 5)
                    .position(x: geometry.size.width * 0.88, y: geometry.size.height * 0.31)
                PixelSquare(size: 6)
                    .position(x: geometry.size.width * 0.73, y: geometry.size.height * 0.88)
                PixelSquare(size: 4)
                    .position(x: geometry.size.width * 0.10, y: geometry.size.height * 0.66)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct PixelSparkle: View {
    let pixelSize: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: pixelSize * 3, height: pixelSize)
            Rectangle()
                .frame(width: pixelSize, height: pixelSize * 3)
        }
        .foregroundStyle(Color(red: 1, green: 0.98, blue: 0.89))
    }
}

private struct PixelSquare: View {
    let size: CGFloat

    var body: some View {
        Rectangle()
            .fill(Color(red: 1, green: 0.43, blue: 0.35))
            .frame(width: size, height: size)
    }
}

#Preview {
    ContentView()
}
