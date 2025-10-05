//
//  LessonView.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
//
// Views/Lesson/LessonView.swift
// Views/Lesson/LessonView.swift
// Views/Lesson/LessonView.swift
// Views/Lesson/LessonView.swift
import SwiftUI
import LiveKit

struct LessonView: View {
    // LiveKit
    @StateObject private var callVM = LessonCallViewModel()
    @EnvironmentObject private var auth: AuthService

    // 発信用（teacher / admin 専用）
        @State private var showingStudentPicker = false
        @State private var students: [UserAdminService.Profile] = []
    
    @State private var incomingInvite: CallInvite? = nil
    
    
    var body: some View {
                    
        ZStack {
            AppBackgroundView()   // ← 背景（ランダムグラデ）
            
            VStack(alignment: .leading, spacing: 12) {
                
                // ====== 上部：カメラ映像ビュー ======
                ZStack {
                    // リモートのみ表示（ローカルへはフォールバックしない） // ★ 今回追記
                    if let remote = firstRemoteVideoTrack() {
                        VideoTile(track: remote)                              // ★ 今回追記
                    } else {                                                  // ★ 今回追記
                        // プレースホルダー                                   // ★ 今回追記
                        VStack(spacing: 8) {                                  // ★ 今回追記
                            Image(systemName: "video.slash")                  // ★ 今回追記
                                .font(.system(size: 34, weight: .regular))    // ★ 今回追記
                            Text(placeholderText())                           // ★ 今回追記
                                .font(.footnote)                              // ★ 今回追記
                                .foregroundStyle(.secondary)                  // ★ 今回追記
                        }                                                     // ★ 今回追記
                    }                                                         // ★ 今回追記
                }
                
                
                
                
                //ZStack {
                    //if let remote = firstRemoteVideoTrack() {
                        //VideoTile(track: remote)
                    //} else if let local = localVideoTrack() {
                        //VideoTile(track: local)
                    //} else {
                        // プレースホルダー
                        //VStack(spacing: 8) {
                            //Image(systemName: "video.slash")
                                //.font(.system(size: 34, weight: .regular))
                            //Text(placeholderText())
                                //.font(.footnote)
                                //.foregroundStyle(.secondary)
                        //}
                    //}
                //}
                .id(callVM.renderTick)                    // ★ 今回追記：tick変化でZStackを再構築100403
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                //.background(Color.black.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Divider().padding(.vertical, 8)
                
                // ===== LiveKit 通話（ここから） =====
                VStack(alignment: .leading, spacing: 10) {
                    Text("LiveKit 通話").font(.headline)
                    
                    if callVM.connecting { ProgressView("接続中…") }
                    
                    if let err = callVM.errorMessage {
                        Text(err).foregroundColor(.red).font(.footnote)
                    }
                    
                    HStack(spacing: 12) {
                        // ▶︎ 役割で分岐
                        if auth.state.role == "teacher" || auth.state.role == "admin" {
                            // 講師/管理者のみ：「通話」→ 生徒選択 → 発信
                            Button("通話") {
                                Task {
                                    do {
                                        let all = try await UserAdminService().fetchAllProfiles()
                                        students = all.filter { $0.role == "student" }
                                        showingStudentPicker = true
                                        
                                        // ✅ 自分も同じ room に接続する
                                        let identity = auth.state.email ?? "guest"
                                        await callVM.connect(roomName: "demo_room_1", identity: identity)
                                        
                                    } catch {
                                        callVM.errorMessage = "ユーザー取得に失敗: \(error.localizedDescription)"
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }else {
                            // 生徒は従来の「入室」
                            Button("入室") {
                                Task {
                                    let identity = auth.state.email ?? "guest"
                                    await callVM.connect(roomName: "demo_room_1", identity: identity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        Button("退出") {
                            callVM.disconnect()
                        }
                        .buttonStyle(.bordered)
                        
                        Button(callVM.isMicEnabled ? "マイクOFF" : "マイクON") {
                            Task { await callVM.toggleMic() }
                        }
                        .buttonStyle(.bordered)
                        
                        Button(callVM.isCamEnabled ? "カメラOFF" : "カメラON") {
                            Task { await callVM.toggleCamera() }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                // ===== LiveKit 通話（ここまで） =====
            }
            .padding()
            
        }
        
        
        .task {
            if let session = try? await SupabaseClientProvider.shared.auth.session {
                let me = session.user.id   // ← Optional じゃないのでそのまま
                _ = await CallInviteService.shared.subscribeIncomingInvites(for: me) { invite in
                    Task { @MainActor in
                        incomingInvite = invite
                    }
                }
            }
        }
        
        // ▼▼ ここを追加：着信シート（生徒側で招待が届いたら表示）
               .sheet(item: $incomingInvite) { invite in
                   VStack(spacing: 20) {
                       Text("通話招待").font(.headline)
                       Text("相手ID: \(invite.fromUserId.uuidString.prefix(8))…")
                           .font(.subheadline)
                           .foregroundStyle(.secondary)

                       HStack(spacing: 16) {
                           Button("拒否") {
                               Task {
                                   try? await CallInviteService.shared.updateStatus(inviteId: invite.id, to: .rejected)
                                   incomingInvite = nil
                               }
                           }
                           .buttonStyle(.bordered)

                           Button("応答") {
                               Task {
                                   // 1) ステータスを accepted に
                                   try? await CallInviteService.shared.updateStatus(inviteId: invite.id, to: .accepted)
                                   // 2) そのまま入室
                                   let identity = auth.state.email ?? "guest"
                                   await callVM.connect(roomName: invite.room, identity: identity)
                                   incomingInvite = nil
                               }
                           }
                           .buttonStyle(.borderedProminent)
                       }
                   }
                   .padding()
               }
        // 生徒選択シート
                .sheet(isPresented: $showingStudentPicker) {
                    NavigationStack {
                        List(students) { s in
                            Button {
                                Task {
                                    do {
                                        _ = try await CallInviteService.shared.createInvite(
                                            toUserId: s.id,
                                            room: "demo_room_1"
                                        )
                                        showingStudentPicker = false
                                        // 送信側はそのまま待ち受け or 入室処理を続ける設計に応じて
                                    } catch {
                                        callVM.errorMessage = "発信に失敗: \(error.localizedDescription)"
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(s.email ?? "(no email)")
                                    Text("role: \(s.role)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .navigationTitle("通話相手を選択")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("閉じる") { showingStudentPicker = false }
                            }
                        }
                    }
                }
            }

    // MARK: - Helpers (映像トラック取得)

    /// 自分の最初の VideoTrack を返す
    private func localVideoTrack() -> VideoTrack? {
        guard let room = callVM.currentRoom else { return nil }
        // localParticipant は non-optional
        return room.localParticipant.videoTracks.first?.track as? VideoTrack
    }

    /// 最初のリモート参加者の最初の VideoTrack を返す
    private func firstRemoteVideoTrack() -> VideoTrack? {
        guard let room = callVM.currentRoom else { return nil }
        guard let remote = room.remoteParticipants.values.first else { return nil }
        return remote.videoTracks.first?.track as? VideoTrack
    }

    private func placeholderText() -> String {
    #if targetEnvironment(simulator)
        return "カメラ映像なし（シミュレーターではカメラ未対応）"
    #else
        return callVM.currentRoom == nil
            ? "未接続：入室すると映像がここに表示されます"
            : (callVM.isCamEnabled ? "映像待機中…" : "カメラOFF")
    #endif
    }
}


