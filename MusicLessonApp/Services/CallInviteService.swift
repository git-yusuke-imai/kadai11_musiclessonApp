//
//  CallInviteService.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/22.
//
// Services/CallInviteService.swift

// Services/CallInviteService.swift

import Foundation
import Supabase
import Realtime

// 招待の状態
enum CallInviteStatus: String, Codable, CaseIterable {
    case pending, accepted, rejected, cancelled, expired
}

// DB レコード
struct CallInvite: Codable, Identifiable {
    let id: UUID
    let room: String
    let fromUserId: UUID
    let toUserId: UUID
    let status: CallInviteStatus
    let createdAt: Date?
    let acceptedAt: Date?
    let rejectedAt: Date?
    let cancelledAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case room
        case fromUserId   = "from_user_id"
        case toUserId     = "to_user_id"
        case status
        case createdAt    = "created_at"
        case acceptedAt   = "accepted_at"
        case rejectedAt   = "rejected_at"
        case cancelledAt  = "cancelled_at"
    }
}

// INSERT 用
private struct NewInvite: Encodable {
    let room: String
    let from_user_id: String
    let to_user_id: String
    let status: String
}

final class CallInviteService {
    static let shared = CallInviteService()
    private init() {}

    private let client = SupabaseClientProvider.shared

    // MARK: - Create

    @discardableResult
    func createInvite(toUserId: UUID, room: String) async throws -> CallInvite {
        let me = try await currentUserID()
        let payload = NewInvite(
            room: room,
            from_user_id: me.uuidString,
            to_user_id: toUserId.uuidString,
            status: CallInviteStatus.pending.rawValue
        )

        let invite: CallInvite = try await client.database
            .from("call_invites")
            .insert(payload)
            .select()
            .single()
            .execute()
            .value

        return invite
    }

    // MARK: - Update

    func updateStatus(inviteId: UUID, to newStatus: CallInviteStatus) async throws {
        struct UpdatePayload: Encodable { let status: String }
        _ = try await client.database
            .from("call_invites")
            .update(UpdatePayload(status: newStatus.rawValue))
            .eq("id", value: inviteId.uuidString)
            .execute()
    }

    // MARK: - Fetch (optional)

    func listMyOutgoing(limit: Int = 20) async throws -> [CallInvite] {
        let me = try await currentUserID()
        let rows: [CallInvite] = try await client.database
            .from("call_invites")
            .select()
            .eq("from_user_id", value: me.uuidString)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return rows
    }

    func listMyPendingIncoming(limit: Int = 20) async throws -> [CallInvite] {
        let me = try await currentUserID()
        let rows: [CallInvite] = try await client.database
            .from("call_invites")
            .select()
            .eq("to_user_id", value: me.uuidString)
            .eq("status", value: CallInviteStatus.pending.rawValue)
            .order("created_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return rows
    }

    // MARK: - Realtime subscribe（暫定版: ポーリングに置換）

    @discardableResult
    func subscribeIncomingInvites(
        for userId: UUID,
        onInsert: @escaping (CallInvite) -> Void
    ) async -> RealtimeChannelV2 {
        // Realtime を使わないが、呼び出し側の型互換のためダミーの channel を返す
        let channel = client.channel("poll_incoming_invites:\(userId.uuidString)")

        // 前回までに見た pending 招待を覚える
        var seen = Set<UUID>()

        Task.detached { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                do {
                    let rows = try await self.listMyPendingIncoming(limit: 50)
                    for inv in rows where inv.toUserId == userId && inv.status == .pending {
                        if !seen.contains(inv.id) {
                            seen.insert(inv.id)
                            onInsert(inv)
                        }
                    }
                } catch {
                    // ログだけ。UI には出さない（過剰通知を避ける）
                    print("poll incoming invites error:", error)
                }
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3秒
            }
        }

        // Realtime 未使用なので subscribe は不要
        return channel
    }

    @discardableResult
    func subscribeStatusUpdates(
        for userId: UUID,
        onUpdate: @escaping (CallInvite) -> Void
    ) async -> RealtimeChannelV2 {
        let channel = client.channel("poll_invite_status:\(userId.uuidString)")

        // 直近のステータスを覚えて変化だけ通知
        var lastStatus: [UUID: CallInviteStatus] = [:]

        Task.detached { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                do {
                    // 自分宛 + 自分発の両方を対象に最新から取得
                    let mineOut   = try await self.listMyOutgoing(limit: 50)
                    let mineIn    = try await self.listMyPendingIncoming(limit: 50) // pending だけだが下で統合
                    // 追加で自分宛/自分発をステータス問わず fetch したい場合は別メソッドを切る

                    // まとめてユニークに（id基準）
                    let merged = Dictionary(uniqueKeysWithValues:
                        (mineOut + mineIn).map { ($0.id, $0) }
                    ).values

                    for inv in merged where inv.toUserId == userId || inv.fromUserId == userId {
                        if lastStatus[inv.id] != inv.status {
                            lastStatus[inv.id] = inv.status
                            onUpdate(inv)
                        }
                    }
                } catch {
                    print("poll status updates error:", error)
                }
                try? await Task.sleep(nanoseconds: 3_000_000_000) // 3秒
            }
        }

        return channel
    }


    // MARK: - Utils

    private func currentUserID() async throws -> UUID {
        guard let session = try? await client.auth.session else {
            throw NSError(
                domain: "CallInviteService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "未ログインです"]
            )
        }
        return session.user.id
    }
}
