//
//  AuthService.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/12.
//

// ファイル: Services/AuthService.swift
// Services/AuthService.swift
// Services/AuthService.swift
import Foundation
import Supabase

struct AuthSessionState {
    var isAuthenticated: Bool
    var email: String?
    var role: String?   // "admin" | "teacher" | "student"
}

final class AuthService: ObservableObject {
    static let shared = AuthService()
    private let client = SupabaseClientProvider.shared

    @Published private(set) var state = AuthSessionState(
        isAuthenticated: false,
        email: nil,
        role: nil
    )

    private var bootstrapTask: Task<Void, Never>?

    init() {
        // init は同期のまま。非同期処理は Task に閉じ込める
        bootstrapTask = Task { [weak self] in
            guard let self else { return }
            try? await self.refreshSession()

            // 認証状態の監視（非 async クロージャ → 内部で Task に包む）
            await self.client.auth.onAuthStateChange { [weak self] _, session in
                Task { @MainActor in
                    guard let self else { return }
                    self.state.isAuthenticated = (session != nil)
                    self.state.email = session?.user.email
                    // セッション変化のたびに role を取り直す
                    if let user = session?.user {
                        await self.fetchUserProfile(userID: user.id)
                    } else {
                        self.state.role = nil
                    }
                }
            }
        }
    }

    deinit { bootstrapTask?.cancel() }

    // MARK: - Public

    @MainActor
    func signUp(email: String, password: String, role _: String) async throws {
        // 役割は DB トリガで student を入れる想定。ここでは auth だけ。
        _ = try await client.auth.signUp(email: email, password: password)
        try await refreshSession()
    }

    @MainActor
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(email: email, password: password)
        try await refreshSession()
    }

    @MainActor
    func signOut() async throws {
        try await client.auth.signOut()
        self.state = AuthSessionState(isAuthenticated: false, email: nil, role: nil)
    }

    @MainActor
    func refreshSession() async throws {
        let session = try? await client.auth.session
        self.state.isAuthenticated = (session != nil)
        self.state.email = session?.user.email
        if let user = session?.user {
            await fetchUserProfile(userID: user.id)
        } else {
            self.state.role = nil
        }
        // 👇 ここに追加
           print("DEBUG: AuthService.state =", self.state)
    }

    // MARK: - Private

    /// profiles から現在ユーザーの role を取得
    @MainActor
    private func fetchUserProfile(userID: UUID) async {
        do {
            // 1件だけ取得（SDKの都合で single()→execute→value を使用）
            let profile: UserProfile = try await client.database
                .from("profiles")
                .select("id,email,role,name,affiliation,course")
                .eq("id", value: userID.uuidString)
                .single()
                .execute()
                .value

            self.state.role = profile.role
            print("DEBUG role =", profile.role)
        } catch {
            print("プロフィール取得失敗:", error)
            self.state.role = nil
        }
    }

}
