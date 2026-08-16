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
        VStack(spacing: 0) {
            // 나중에 프로필·에너지·코인·주문 칸이 들어갈 상단 영역입니다.
            // 현재는 머지 보드 위치를 확인하기 위해 빈 여백으로 둡니다.
            Color.clear
                .frame(height: 170)

            // SpriteKit으로 그리는 7 × 9 머지 보드 영역입니다.
            SpriteView(scene: boardScene)
                .background(Color(red: 0.97, green: 0.93, blue: 0.84))

            // 나중에 안내 문구가 들어갈 하단 영역입니다.
            Color.clear
                .frame(height: 76)
        }
        .background(Color(red: 0.98, green: 0.96, blue: 0.90))
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    ContentView()
}
