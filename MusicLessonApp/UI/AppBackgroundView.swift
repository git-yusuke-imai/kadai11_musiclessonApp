//
//  AppBackgroundView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/25.
//

import SwiftUI

// 起動中は色配置が固定になる乱数生成器
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    init(seed: UInt64) { self.state = seed &+ 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

struct AppBackgroundView: View {
    @State private var seed: UInt64 = UInt64(Date().timeIntervalSince1970)

    // 濃淡を増やしたパレット（緑基調＋シアン系）
    private let palette: [Color] = [
        Color(#colorLiteral(red: 0.18, green: 0.75, blue: 0.55, alpha: 1)), // 明るめグリーン
        Color(#colorLiteral(red: 0.12, green: 0.60, blue: 0.45, alpha: 1)), // 中間グリーン
        Color(#colorLiteral(red: 0.05, green: 0.40, blue: 0.30, alpha: 1)), // 濃いめグリーン
        Color.mint.opacity(0.85),
        Color.teal.opacity(0.85),
        Color.cyan.opacity(0.75),
        Color.green.opacity(0.65),
        Color(#colorLiteral(red: 0.6160776019, green: 0.9458486438, blue: 0.7325856686, alpha: 1)), // ライトグリーン
        Color(#colorLiteral(red: 0.40, green: 0.80, blue: 0.60, alpha: 1))  // ライム寄り
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ベースの斜めグラデ（明るめに寄せた）
                LinearGradient(
                    colors: [
                        Color(#colorLiteral(red: 0.16, green: 0.68, blue: 0.52, alpha: 1)),
                        Color(#colorLiteral(red: 0.21, green: 0.78, blue: 0.60, alpha: 1))
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // ランダムぼかしブロブ
                Canvas { ctx, size in
                    var rng = SeededGenerator(seed: seed)
                    for _ in 0..<8 {
                        let r = CGFloat.random(in: 180...360, using: &rng)
                        let x = CGFloat.random(in: -r...size.width + r, using: &rng)
                        let y = CGFloat.random(in: -r...size.height + r, using: &rng)
                        let color = palette.randomElement(using: &rng)!.opacity(0.40)

                        let rect = CGRect(x: x, y: y, width: r, height: r)
                        let center = CGPoint(x: rect.midX, y: rect.midY)

                        ctx.fill(
                            Path(ellipseIn: rect),
                            with: .radialGradient(
                                Gradient(colors: [color, .clear]),
                                center: center,
                                startRadius: 0,
                                endRadius: r
                            )
                        )
                    }
                }
                .blur(radius: 70)
                .blendMode(.plusLighter)

                // うっすら光
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.05), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blendMode(.overlay)

                // ビネット
                LinearGradient(
                    colors: [.black.opacity(0.15), .clear, .black.opacity(0.18)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()
        }
    }
}
