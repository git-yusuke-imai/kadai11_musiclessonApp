//
//  PracticeView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
//

import SwiftUI

struct PracticeView: View {
    @StateObject private var metro = Metronome()
    @StateObject private var rec = Recorder()
    @State private var permissionGranted = false

    var body: some View {
        
        ZStack {
            // ★ ここで画面全体に背景を敷く（最背面）
            AppBackgroundView()
            
            VStack(spacing: 20) {
                
                // ← レッスンコンテンツを追加
                LessonStudySection()
                
                Divider()            // メトロノーム
                VStack {
                    Text("メトロノーム").font(.headline)
                    HStack {
                        Slider(value: $metro.bpm, in: 40...200, step: 1)
                        Text("\(Int(metro.bpm)) BPM").monospaced()
                    }
                    HStack {
                        Button("スタート") { metro.start() }
                        Button("ストップ") { metro.stop() }
                    }
                }
                
                Divider()
                
                // 録音
                VStack {
                    Text("録音").font(.headline)
                    HStack {
                        Button(rec.isRecording ? "録音停止" : "録音開始") {
                            if rec.isRecording {
                                rec.stop()
                            } else {
                                if permissionGranted {
                                    rec.start()
                                } else {
                                    rec.requestPermission { ok in
                                        DispatchQueue.main.async {
                                            permissionGranted = ok
                                            if ok { rec.start() }
                                        }
                                    }
                                }
                            }
                        }
                        Button("再生") { rec.playBack() }
                    }
                }
            }
            .padding()
        }
    }
}
