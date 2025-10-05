//
//   LiveKitManager.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/04.
//

import Foundation
import Combine
import LiveKit
import AVFoundation   // ← iOSマイク権限用

@MainActor
final class LiveKitManager: ObservableObject {
    let room = Room()

    @Published private(set) var isConnected = false
    @Published var isMicEnabled = false

    func connect(token: String) async {
        do {
            // iOSのみ: AudioSession 初期化 & マイク権限リクエスト
#if os(iOS)
let session = AVAudioSession.sharedInstance()
try? session.setCategory(.playAndRecord,
                         mode: .default,
                         options: [.defaultToSpeaker, .allowBluetooth])
try? session.setActive(true)

// 権限リクエスト
let granted: Bool
if #available(iOS 17.0, *) {
    // iOS17+ はこちら
    granted = await AVAudioApplication.requestRecordPermission()
} else {
    // iOS16 以下はこちら
    granted = await withCheckedContinuation { cont in
        session.requestRecordPermission { ok in cont.resume(returning: ok) }
    }
}
print("mic permission granted =", granted)

// デバッグ: Info.plist にキーが入ってるか確認
print("NSMicrophoneUsageDescription =",
      Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") as? String ?? "nil")
            
            // 現在の権限状態をログ
            switch session.recordPermission {
            case .undetermined: print("[Mic] permission = undetermined")
            case .denied:       print("[Mic] permission = denied")
            case .granted:      print("[Mic] permission = granted")
            @unknown default:   print("[Mic] permission = unknown")
            }
            
#endif

            // LiveKit へ接続
            try await room.connect(
                url: AppConfig.livekitURL,
                token: token
            )
            isConnected = true

            // マイクを有効化（LiveKit SDK API）
            do {
                try await room.localParticipant.setMicrophone(enabled: true)
                isMicEnabled = true
            } catch {
                print("mic publish fallback:", error)
            }

            print("connected to LiveKit")
        } catch {
            print("LiveKit connect error:", error)
        }
    }

    func disconnect() {
        Task {
            await room.disconnect()
            isConnected = false
            isMicEnabled = false
        }
    }

    func toggleMic() {
        Task {
            let next = !isMicEnabled
            do {
                try await room.localParticipant.setMicrophone(enabled: next)
                isMicEnabled = next
            } catch {
                print("toggle mic error:", error)
            }
        }
    }
}
