//
//  ContentView.swift
//  Merge
//
//  Created by 이윤진 on 8/16/26.
//

import Combine
import SpriteKit
import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var energyStore = EnergyStore()

    // SpriteKit 게임판입니다. 화면 크기에 맞춰 장면의 크기도 바뀝니다.
    @State private var boardScene: MergeBoardScene = {
        let scene = MergeBoardScene()
        scene.scaleMode = .resizeFill
        return scene
    }()

    // 실제 회복량은 저장된 시각 차이로 계산하고, 이 타이머는 화면 표시만 매초 갱신합니다.
    private let energyTicker = Timer.publish(
        every: 1,
        on: .main,
        in: .common
    ).autoconnect()

    var body: some View {
        ZStack {
            // 상단·SpriteKit·하단 영역 뒤로 하나의 픽셀 하늘 배경이 이어집니다.
            PixelSkyBackground()

            VStack(spacing: 0) {
                // 에너지부터 구현하고, 코인과 주문 칸은 후속 이슈에서 이 영역에 추가합니다.
                VStack(spacing: 0) {
                    HStack {
                        EnergyStatusView(
                            currentEnergy: energyStore.currentEnergy,
                            maximumEnergy: energyStore.maximumEnergy,
                            secondsUntilNextRecovery: energyStore.secondsUntilNextRecovery
                        )

                        Spacer()
                    }
                    .padding(.top, 14)
                    .padding(.horizontal, 24)

                    Spacer()
                }
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
        .onAppear {
            // SpriteKit은 빈 칸을 확인한 뒤 이 클로저를 호출해 성공할 스폰의 에너지만 차감합니다.
            boardScene.consumeEnergyForSpawn = { [weak energyStore] in
                energyStore?.consumeForSuccessfulSpawn() ?? false
            }
            energyStore.refresh()
        }
        .onReceive(energyTicker) { date in
            energyStore.refresh(at: date)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // 백그라운드나 앱 종료 중 흐른 시간을 화면에 복귀할 때 즉시 반영합니다.
                energyStore.refresh()
            }
        }
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
                PixelSparkle(pixelSize: 3)
                    .position(x: geometry.size.width * 0.48, y: geometry.size.height * 0.23)
                PixelSparkle(pixelSize: 2)
                    .position(x: geometry.size.width * 0.91, y: geometry.size.height * 0.27)
                PixelSparkle(pixelSize: 4)
                    .position(x: geometry.size.width * 0.18, y: geometry.size.height * 0.82)
                PixelSparkle(pixelSize: 3)
                    .position(x: geometry.size.width * 0.84, y: geometry.size.height * 0.74)
                PixelSparkle(pixelSize: 2)
                    .position(x: geometry.size.width * 0.50, y: geometry.size.height * 0.93)

                PixelSquare(size: 6)
                    .position(x: geometry.size.width * 0.32, y: geometry.size.height * 0.09)
                PixelSquare(size: 5)
                    .position(x: geometry.size.width * 0.88, y: geometry.size.height * 0.31)
                PixelSquare(size: 4)
                    .position(x: geometry.size.width * 0.67, y: geometry.size.height * 0.14)
                PixelSquare(size: 5)
                    .position(x: geometry.size.width * 0.09, y: geometry.size.height * 0.27)
                PixelSquare(size: 6)
                    .position(x: geometry.size.width * 0.73, y: geometry.size.height * 0.88)
                PixelSquare(size: 4)
                    .position(x: geometry.size.width * 0.10, y: geometry.size.height * 0.66)
                PixelSquare(size: 4)
                    .position(x: geometry.size.width * 0.91, y: geometry.size.height * 0.90)
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
