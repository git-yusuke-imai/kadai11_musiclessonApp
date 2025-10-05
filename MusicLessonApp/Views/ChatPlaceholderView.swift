//
//  ChatPlaceholderView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
//

import SwiftUI

struct ChatPlaceholderView: View {
    @StateObject private var livekit = LiveKitManager()
    @StateObject private var meter = AudioLevelMeter()
    @State private var token: String =
        ""

    var body: some View {
        VStack(spacing: 20) {
            Text("LiveKit 接続テスト")
                .font(.headline)

            SecureField("Token", text: $token)
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .padding(.horizontal)

            // 🎚️ ミニメーター
            MicLevelBar(level: meter.level, micOn: livekit.isMicEnabled)
            

            // 接続・切断
            HStack {
                Button("Connect") {
                    Task {
                        await livekit.connect(token: token)
                        await meter.start()
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Disconnect") {
                    livekit.disconnect()
                    meter.stop()
                }
                .buttonStyle(.bordered)
            }

            // マイク ON/OFF
            HStack {
                Button(livekit.isMicEnabled ? "Mic OFF" : "Mic ON") {
                    livekit.toggleMic()
                }
                .buttonStyle(.bordered)
                .disabled(!livekit.isConnected)

                if livekit.isConnected {
                    Text(livekit.isMicEnabled ? "🎙️ 送信中" : "🔇 ミュート")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

