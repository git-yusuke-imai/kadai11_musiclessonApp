//
//  Config.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/04.
//

// ファイル: MusicLessonApp/Config/AppConfig.swift
import Foundation

struct AppConfig {
    // --- Supabase ---
    static var supabaseURL: String {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              s.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("http") else {
            fatalError("SUPABASE_URL が未設定/不正です（iOS-Info.plist と Secrets.xcconfig を確認）")
        }
        return s
    }

    static var supabaseAnonKey: String {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String,
              !s.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            fatalError("SUPABASE_ANON_KEY が未設定です（Secrets.xcconfig を確認）")
        }
        return s
    }

    // --- LiveKit（Docker のトークンサーバ利用時は URL だけでOK）---
    static var livekitURL: String {
        guard let s = Bundle.main.object(forInfoDictionaryKey: "LIVEKIT_URL") as? String,
              s.hasPrefix("ws://") || s.hasPrefix("wss://") else {
            fatalError("LIVEKIT_URL が未設定/不正です（例: ws://127.0.0.1:7880）")
        }
        return s
    }
}
