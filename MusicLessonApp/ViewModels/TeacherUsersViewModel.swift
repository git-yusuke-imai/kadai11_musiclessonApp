//
//  TeacherUsersViewModel.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/23.
//

import Foundation

/// 講師専用：学生一覧＋編集用 ViewModel
/// 基本は AdminUsersViewModel と同構成だが、
/// fetchAllProfiles() の結果から student のみを対象に扱う
@MainActor
final class TeacherUsersViewModel: ObservableObject {
    @Published var users: [UserAdminService.Profile] = []
    @Published var loading = false
    @Published var errorMessage: String?

    // 編集用
    @Published var editingUserID: UUID?
    @Published var editingEmail: String = ""
    @Published var editingRole: String = "student"
    @Published var editingName: String = ""
    @Published var editingAffiliation: String = ""
    @Published var editingCourse: String = ""
    @Published var showingEditor = false

    private let service = UserAdminService()

    /// 学生のみ取得
    func load() async {
        loading = true; errorMessage = nil
        defer { loading = false }
        do {
            let all = try await service.fetchAllProfiles()
            users = all.filter { $0.role == "student" }
        } catch {
            errorMessage = "ユーザー取得に失敗: \(error.localizedDescription)"
        }
    }

    /// 行の「変更」ボタンで呼ぶ
    func beginEdit(userID: UUID, user: UserAdminService.Profile) {
        editingUserID = userID
        editingEmail = user.email ?? ""
        editingRole = user.role
        editingName = user.name ?? ""
        editingAffiliation = user.affiliation ?? ""
        editingCourse = user.course ?? ""
        showingEditor = true
    }

    func cancelEdit() {
        showingEditor = false
        editingUserID = nil
    }

    func saveEdits() async {
        guard let userID = editingUserID else { return }
        loading = true; errorMessage = nil
        defer { loading = false }

        do {
            try await service.updateProfile(
                userID: userID,
                role: editingRole,
                name: editingName.isEmpty ? nil : editingName,
                affiliation: editingAffiliation.isEmpty ? nil : editingAffiliation,
                course: editingCourse.isEmpty ? nil : editingCourse
            )
            let all = try await service.fetchAllProfiles()
            users = all.filter { $0.role == "student" }
            showingEditor = false
            editingUserID = nil
        } catch {
            errorMessage = "保存に失敗: \(error.localizedDescription)"
        }
    }
}
