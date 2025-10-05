//
//  TeacherCallSetupView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/23.
//

import SwiftUI

/// 講師専用：通話セット用ビュー（studentsのみ表示）
struct TeacherCallSetupView: View {
    @StateObject private var vm = TeacherUsersViewModel()   // ← Teacher用VM

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.users.filter { $0.role == "student" }) { u in
                    StudentRowView(user: u) {
                        vm.beginEdit(userID: u.id, user: u)
                    }
                }
            }
            .navigationTitle("通話セット（講師）")
            .task { await vm.load() }
            .sheet(isPresented: $vm.showingEditor) {
                EditorSheetT(vm: vm)                     // ← Teacher用Editorに変更
            }
            .overlay {
                if vm.loading { ProgressView().controlSize(.large) }
            }
            .alert("エラー", isPresented: .constant(vm.errorMessage != nil), actions: {
                Button("OK") { vm.errorMessage = nil }
            }, message: {
                Text(vm.errorMessage ?? "")
            })
        }
    }
}

/// 学生行（講師向け表示）
private struct StudentRowView: View {
    let user: UserAdminService.Profile
    let onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.email ?? "(no email)")
                Text("student").font(.footnote).foregroundStyle(.secondary)
                if let name = user.name, !name.isEmpty { Text("氏名: \(name)").font(.footnote) }
                if let aff = user.affiliation, !aff.isEmpty { Text("所属: \(aff)").font(.footnote) }
                if let c = user.course, !c.isEmpty { Text("コース: \(c)").font(.footnote) }
            }
            Spacer()
            Button("変更", action: onEdit).buttonStyle(.bordered)
        }
    }
}

/// 編集シート（講師用）— ViewModel 型を Teacher に合わせる
private struct EditorSheetT: View {
    @ObservedObject var vm: TeacherUsersViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("アカウント") {
                    TextField("メール", text: $vm.editingEmail).disabled(true)
                    Picker("ロール", selection: $vm.editingRole) {
                        Text("student").tag("student")
                        Text("teacher").tag("teacher")
                    }
                    .pickerStyle(.segmented)
                }
                Section("プロフィール") {
                    TextField("氏名", text: $vm.editingName)
                    TextField("所属（例: 東京校）", text: $vm.editingAffiliation)
                    TextField("コース（例: 週2レッスン）", text: $vm.editingCourse)
                }
            }
            .navigationTitle("ユーザー編集（講師）")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { vm.cancelEdit() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { Task { await vm.saveEdits() } }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
