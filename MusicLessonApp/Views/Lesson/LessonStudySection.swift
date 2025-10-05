//
//  LessonStudySection.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/20.
//

import SwiftUI

struct LessonStudySection: View {
    @State private var index: Int = UserDefaults.standard.integer(forKey: "lessonIndex")
    @StateObject private var player = AudioPlayer()
    @State private var loopOn = false
    @State private var rate: Float = 1.0

    var body: some View {
        let lessons = LessonData.all
        let current = lessons[index]
        
        ZStack {
            // ★ ここを差し替え（AppBackgroundView を直に敷く）
            //AppBackgroundView()
            
            // 背景は透過（RootTabView の AppBackgroundView が見える）
                       Color.clear
            
        VStack(alignment: .leading, spacing: 12) {
            // タイトル
            Text(current.title).font(.title2).bold()
            
            // 譜面
            if let img = current.sheetImageName {
                ZStack(alignment: .topTrailing) {
                    SheetImageView(name: img).frame(height: 240)
                        .background(.clear) // 念のため
                    Text("ピンチで拡大 / ドラッグ移動")
                        .font(.caption)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(6)
                }
                .padding()
                .background(.clear) // ← 最外にこれを付ける
            }
            
            // 本文
            ScrollView {
                Text(current.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(.clear)
            
            // オーディオ
            if let name = current.audioFileName {
                VStack(spacing: 8) {
                    HStack {
                        Button(player.isPlaying ? "一時停止" : "再生") {
                            if player.isPlaying { player.togglePause() }
                            else { player.play(named: name, loop: loopOn, rate: rate) }
                        }
                        Button("停止") { player.stop() }
                        Toggle("ループ", isOn: $loopOn).labelsHidden()
                        Spacer()
                    }
                    
#if os(iOS)
                    HStack {
                        Text("速度").font(.caption)
                        Slider(
                            value: Binding(get: { Double(rate) }, set: { rate = Float($0) }),
                            in: 0.5...1.5, step: 0.05
                        )
                        Text(String(format: "%.2fx", rate)).font(.caption).monospacedDigit()
                    }
#endif
                    
                    HStack {
                        Text(timeString(player.currentTime)).font(.caption).monospacedDigit()
                        Slider(value: Binding(
                            get: { player.duration > 0 ? player.currentTime / player.duration : 0 },
                            set: { pct in player.seek(to: pct * player.duration) }
                        ))
                        Text(timeString(player.duration)).font(.caption).monospacedDigit()
                    }
                }
                .background(.clear)
            }
            
            // 前後
            HStack {
                Button("Back") {
                    index = max(index - 1, 0)
                    UserDefaults.standard.set(index, forKey: "lessonIndex")
                }.disabled(index == 0)
                Spacer()
                Button("Next") {
                    index = min(index + 1, lessons.count - 1)
                    UserDefaults.standard.set(index, forKey: "lessonIndex")
                }.disabled(index == lessons.count - 1)
            }
            .padding()
            .background(.clear)
        }
        .padding(.horizontal)        // 外周の余白は維持
                    .background(.clear)
    }
        .background(.clear)              // 念押し（このビュー自身の背景を透明に）
            }

    private func timeString(_ t: TimeInterval) -> String {
        guard t.isFinite else { return "--:--" }
        let m = Int(t) / 60, s = Int(t) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
