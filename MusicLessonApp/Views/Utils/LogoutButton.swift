//
//  LogoutButton.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/18.
//

import SwiftUI

struct LogoutButton: View {
    @State private var isBusy = false

    var body: some View {
        Button {
            Task {
                guard !isBusy else { return }
                isBusy = true
                defer { isBusy = false }
                try? await AuthService.shared.signOut()
            }
        } label: {
            Group {
                if isBusy {
                    ProgressView()
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .imageScale(.large)
                }
            }
            .frame(width: 44, height: 44)
            .background(.ultraThinMaterial, in: Circle())
            .shadow(radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("ログアウト")
    }
}
