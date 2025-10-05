//
//  GlassOutlineButtonStyle.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/26.
//

import SwiftUI

/// 透過＋白枠ぼかしの共通ボタンスタイル
struct GlassOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.12)) // 薄い白背景
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.18, dampingFraction: 0.85),
                       value: configuration.isPressed)
    }
}
