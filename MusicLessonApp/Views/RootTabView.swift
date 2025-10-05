//
//  RootTabView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
// Views/RootTabView.swift
import SwiftUI

struct RootTabView: View {
    @StateObject private var auth = AuthService.shared

    private var isAdmin: Bool {
        (auth.state.role ?? "").lowercased() == "admin"
    }
    
    private var isTeacher: Bool {
            (auth.state.role ?? "").lowercased() == "teacher"
        }

    var body: some View {
        
        ZStack {
            AppBackgroundView()                // ← これを一枚敷く（全タブに効く）
            
            Group {
                if auth.state.isAuthenticated {
                    ZStack(alignment: .topTrailing) {
                        tabsContent
                        
                        // 右上: 丸いログアウトボタン
                        Button {
                            Task { try? await auth.signOut() }
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Color.red.opacity(0.9)))
                                .shadow(radius: 3, y: 2)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 12)
                        .padding(.trailing, 16)
                        
                        // 右上・少し左に現在 role を小さく表示（デバッグ用）
                        if let role = auth.state.role {
                            Text("role: \(role)")
                                .font(.caption2)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(.thinMaterial, in: Capsule())
                                .padding(.top, 16)
                                .padding(.trailing, 72) // ログアウトボタンの左に寄せる
                        }
                    }
                } else {
                    AuthView()
                }
            }
        }
        
        // ▼ ナビゲーションバーを透過化
               .toolbarBackground(.hidden, for: .navigationBar)
               .toolbarColorScheme(.light, for: .navigationBar)
        
        // 画面表示時に最新セッション/role を再取得
        .task { try? await auth.refreshSession() }
    }

    @ViewBuilder
    private var tabsContent: some View {
        #if os(macOS)
        TabView {
            LessonView()
                .tabItem { Label("レッスン", systemImage: "book") }

            PracticeView()
                .tabItem { Label("教材", systemImage: "metronome") }

            //ChatPlaceholderView()
                //.tabItem { Label("チャット", systemImage: "bubble.left.and.bubble.right") }

            if isTeacher {
                            TeacherPanelView()
                                .tabItem { Label("講師", systemImage: "person.2") }
                        }
            
            if isAdmin {
                AdminPanelView()
                    .tabItem { Label("管理", systemImage: "gear") }
            }
        }
        .padding()
        #else
        TabView {
            LessonView()
                .tabItem { Label("レッスン", systemImage: "book") }

            PracticeView()
                .tabItem { Label("教材", systemImage: "metronome") }

            //ChatPlaceholderView()
                //.tabItem { Label("チャット", systemImage: "bubble.left.and.bubble.right") }

            if isTeacher {
                            TeacherPanelView()
                                .tabItem { Label("講師", systemImage: "person.2") }
                        }
            
            if isAdmin {
                AdminPanelView()
                    .tabItem { Label("管理", systemImage: "gear") }
            }
        }
        // ↓ これがポイント（TabView自体の不透明背景を外す）
               .background(Color.clear)
               .toolbarBackground(.hidden, for: .tabBar)
        #endif
    }
}
