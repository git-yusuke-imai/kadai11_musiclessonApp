//
//  AdminPanelView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/17.
//

// ファイル: Views/Admin/AdminPanelView.swift
import SwiftUI

struct AdminPanelView: View {
    var body: some View {
        NavigationStack {
            List {
                // すでに AdminUsersView.swift があるならここにリンク
                NavigationLink("ユーザー管理", destination: AdminUsersView())
                // これから増える管理機能をここに足していけばOK
            }
            .navigationTitle("管理者パネル")
        }
    }
}
