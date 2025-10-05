//
//  AuthViewModel.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/12.
//

// ファイル: ViewModels/AuthViewModel.swift
import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    enum Mode { case login, signup }
    
    @Published var mode: Mode = .login
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var role: String = "student"   // ← 初期値を生徒
    @Published var loading = false
    @Published var errorMessage: String?
    
    func submit() async {
        errorMessage = nil
        guard Validators.isValidEmail(email) else {
            errorMessage = "メール形式が不正です"
            return
        }
        guard Validators.isValidPassword(password) else {
            errorMessage = "パスワードは6文字以上にしてください"
            return
        }
        loading = true
        defer { loading = false }
        do {
            switch mode {
            case .login:
                try await AuthService.shared.signIn(email: email, password: password)
            case .signup:
                try await AuthService.shared.signUp(email: email, password: password, role: role)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
