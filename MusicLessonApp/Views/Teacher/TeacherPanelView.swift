//
//  TeacherPanelView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/23.
//

import SwiftUI

/// 講師専用パネル
/// AdminPanelView と同じ構成で、講師向け機能をここに追加していく
struct TeacherPanelView: View {
    var body: some View {
        NavigationStack {
            List {
                // 生徒アカウントの通話セット画面へ
                NavigationLink("通話セット", destination: TeacherCallSetupView())
                // 今後、講師向けの管理機能を追加する場合はここに追記
            }
            .navigationTitle("講師パネル")
        }
    }
}
