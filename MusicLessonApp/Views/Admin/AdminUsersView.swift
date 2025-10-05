//
//  AdminUsersView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/17.
//

// Views/Admin/AdminUsersView.swift
import SwiftUI

struct AdminUsersView: View {
    @StateObject private var vm = AdminUsersViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.users) { u in
                    UserRowView(user: u) {
                        vm.beginEdit(userID: u.id, user: u)
                    }
                }
            }
            .navigationTitle("ユーザー管理")
            .task { await vm.load() }
            .sheet(isPresented: $vm.showingEditor) {
                EditorSheet(vm: vm)
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

/// 一覧の1行
private struct UserRowView: View {
    let user: UserAdminService.Profile
    let onEdit: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.email ?? "(no email)")
                Text(user.role)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let name = user.name, !name.isEmpty {
                    Text("氏名: \(name)").font(.footnote)
                }
                if let aff = user.affiliation, !aff.isEmpty {
                    Text("所属: \(aff)").font(.footnote)
                }
                if let c = user.course, !c.isEmpty {
                    Text("コース: \(c)").font(.footnote)
                }
            }
            Spacer()
            Button("変更", action: onEdit)
                .buttonStyle(.bordered)
        }
    }
}

/// 編集シート
private struct EditorSheet: View {
    @ObservedObject var vm: AdminUsersViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("アカウント") {
                    TextField("メール", text: $vm.editingEmail)
                        .disabled(true)
                    Picker("ロール", selection: $vm.editingRole) {
                        Text("student").tag("student")
                        Text("teacher").tag("teacher")
                        Text("admin").tag("admin")
                    }
                    .pickerStyle(.segmented)
                }
                Section("プロフィール") {
                    TextField("氏名", text: $vm.editingName)
                    TextField("所属（例: 東京校）", text: $vm.editingAffiliation)
                    TextField("コース（例: 週2レッスン）", text: $vm.editingCourse)
                }
            }
            .navigationTitle("ユーザー編集")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { vm.cancelEdit() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task { await vm.saveEdits() }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}
