//
//  MicLevelBar.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/09.
//

import SwiftUI

struct MicLevelBar: View {
    var level: Float // 0...1
    let micOn: Bool         // ← これを追加

    init(level: Float, micOn: Bool = true) {
            // 万一はみ出しても 0...1 に丸める
            self.level = max(0, min(1, level))
            self.micOn = micOn
        }
    

    var body: some View {
           GeometryReader { geo in
               ZStack(alignment: .leading) {
                   // 背景（ゲージの空部分）
                   RoundedRectangle(cornerRadius: 3)
                       .fill(Color.secondary.opacity(0.2))

                   // レベル表示（マイクONで色が変わる）
                   RoundedRectangle(cornerRadius: 3)
                       .fill(micOn ? Color.green : Color.gray)
                       .frame(width: CGFloat(level) * geo.size.width)
               }
           }
           .frame(height: 6)
        .animation(.easeOut(duration: 0.08), value: level)
        .accessibilityLabel("Microphone level")
    }
}
