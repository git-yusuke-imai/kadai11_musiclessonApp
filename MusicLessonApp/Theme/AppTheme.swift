//
//  AppTheme.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/25.
//

import SwiftUI

enum AppTheme {
    // 好きに微調整OK
    //static let bgTop     = Color(#colorLiteral(red: 0, green: 0.5089641213, blue: 0.4877259731, alpha: 1)) // 濃いグリーン
    //static let bgBottom  = Color(#colorLiteral(red: 0.05, green: 0.65, blue: 0.55, alpha: 1)) // 明るめグリーン
    static let bgTop       = Color(.sRGB, red: 0.12, green: 0.60, blue: 0.53, opacity: 1.0)
    static let bgBottom    = Color(.sRGB, red: 0.18, green: 0.75, blue: 0.55, opacity: 1.0)
    static let lightBlue = Color(red: 0.3, green: 0.7, blue: 1.0) // 明るめの青
    static let greenPrimary = Color(red: 0.2, green: 0.8, blue: 0.6) // 参考
    static let chrome    = Color.black.opacity(0.30)  // 透過ボタンの背景
    static let icon      = Color.white                // アイコン色
}

