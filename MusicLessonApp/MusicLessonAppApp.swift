//
//  MusicLessonAppApp.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
//
import SwiftUI

@main
struct MusicLessonAppApp: App {
    @StateObject private var auth = AuthService.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.state.isAuthenticated {
                    RootTabView()
                } else {
                    AuthView()
                }
            }
            .environmentObject(auth)   // 子Viewで使う場合に備えて渡す
        }
        #if os(macOS)
        .windowStyle(.titleBar)
        #endif
    }
}
