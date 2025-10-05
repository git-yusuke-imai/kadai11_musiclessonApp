//
//  HomeView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/13.
//

// ファイル: Views/HomeView.swift
import SwiftUI

struct HomeView: View {
    @ObservedObject private var auth = AuthService.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("ログイン中: \(auth.state.email ?? "不明")")
                Text("権限: \(auth.state.role ?? "未設定")")
                
                if auth.state.role == "teacher" {
                    Button("レッスンコードを発行する") {
                        // ここに LiveKit トークン発行処理を呼び出す
                        print("トークン発行処理")
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if auth.state.role == "teacher" {
                                  Section {
                                      Text("講師メニュー")
                                          .font(.headline)
                                      NavigationLink("通話セット", destination: TeacherPanelView())
                                  }
                                  .padding(.top, 12)
                              }
                
                if auth.state.role == "admin" {
                    Section {
                        Text("管理者メニュー")
                            .font(.headline)
                        Button("ユーザー管理（後で実装）") {
                            // TODO: 後でユーザー一覧/削除UIを実装
                        }
                    }
                    .padding(.top, 12)
                }
                
                Button("サインアウト") {
                    Task { try? await auth.signOut() }
                }
            }
            .padding()
            .navigationTitle("ホーム")
        }
    }
}
