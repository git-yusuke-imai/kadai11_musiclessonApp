//
//  UserAdminService.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/17.
//

//  UserAdminService.swift
//  MusicLessonApp

// Services/UserAdminService.swift
import Foundation
import Supabase

final class UserAdminService {
    private let client = SupabaseClientProvider.shared

    struct Profile: Decodable, Identifiable {
        let id: UUID
        let email: String?
        let role: String
        let name: String?
        let affiliation: String?
        let course: String?
    }

    /// 全ユーザー取得（admin の RLS で全件 select 可）
    func fetchAllProfiles() async throws -> [Profile] {
        let rows: [Profile] = try await client.database
            .from("profiles")
            .select("id,email,role,name,affiliation,course")
            .order("created_at", ascending: true)
            .execute()
            .value
        return rows
    }

    /// ロールのみ更新（既存のまま残します）
    func updateUserRole(targetUserID: UUID, to role: String) async throws {
        precondition(["student","teacher","admin"].contains(role))
        _ = try await client.database
            .from("profiles")
            .update(["role": role])
            .eq("id", value: targetUserID.uuidString)
            .execute()
    }

    /// 氏名/所属/コース/ロールのうち、渡されたものだけ更新
    func updateProfile(
        userID: UUID,
        role: String? = nil,
        name: String? = nil,
        affiliation: String? = nil,
        course: String? = nil
    ) async throws {
        var payload: [String: AnyEncodable] = [:]
        if let role { payload["role"] = AnyEncodable(role) }
        if let name { payload["name"] = AnyEncodable(name) }
        if let affiliation { payload["affiliation"] = AnyEncodable(affiliation) }
        if let course { payload["course"] = AnyEncodable(course) }

        guard !payload.isEmpty else { return }

        _ = try await client.database
            .from("profiles")
            .update(payload)
            .eq("id", value: userID.uuidString)
            .execute()
    }
}
