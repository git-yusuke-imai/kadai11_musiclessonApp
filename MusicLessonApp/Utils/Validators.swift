//
//  Validators.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/14.
//

// Utils/Validators.swift
import Foundation

enum Validators {
    static func isValidEmail(_ value: String) -> Bool {
        let v = value.trimmingCharacters(in: .whitespacesAndNewlines)
        // シンプル判定（必要なら後で正規表現を強化）
        return v.contains("@") && v.contains(".") && v.count >= 5
    }

    static func isValidPassword(_ value: String) -> Bool {
        value.count >= 6
    }
}
