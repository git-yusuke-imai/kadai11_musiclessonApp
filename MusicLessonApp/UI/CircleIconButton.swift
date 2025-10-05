//
//  CircleIconButton.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/25.
//

import SwiftUI

struct CircleIconButton: View {
    let systemName: String
    var size: CGFloat = 60
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(AppTheme.icon)
                .frame(width: size, height: size)
                .background(AppTheme.chrome, in: Circle())
                .shadow(radius: 6, y: 3) // うっすら浮かせる
        }
        .buttonStyle(.plain)
    }
}
