//
//  SupabaseClientProvider.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/14.
//
// ファイル: MusicLessonApp/Services/SupabaseClientProvider.swift
import Foundation
import Supabase

enum SupabaseClientProvider {
    static let shared: SupabaseClient = {
        // ここで必ず実値をログ出しして配線ミスを即断
        let urlString = AppConfig.supabaseURL
        let key = AppConfig.supabaseAnonKey
        print("⚙️ DEBUG SUPABASE_URL =", urlString)
        print("⚙️ DEBUG SUPABASE_KEY prefix =", key.prefix(8))

        // 置換失敗の典型: "$(SUPABASE_URL)" のまま / 空 / 余白
        if urlString.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("$(") {
            preconditionFailure("SUPABASE_URL が $(SUPABASE_URL) のまま。Target > Info > Configurations で Secrets.xcconfig を割り当ててください。")
        }
        if key.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("$(") || key.isEmpty {
            preconditionFailure("SUPABASE_ANON_KEY が未設定。Secrets.xcconfig を確認。")
        }

        guard let url = URL(string: urlString) else {
            preconditionFailure("Supabase URL が不正: \(urlString)")
        }
        return SupabaseClient(supabaseURL: url, supabaseKey: key)
    }()
}

