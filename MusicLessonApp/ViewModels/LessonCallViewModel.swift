//
//  LessonCallViewModel.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/20.
//

//  LessonCallViewModel.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/20.
//

import Foundation
import LiveKit
import AVFoundation

@MainActor
final class LessonCallViewModel: ObservableObject {
    @Published var connecting = false
    @Published var errorMessage: String?
    @Published var isMicEnabled = false
    @Published var isCamEnabled = false

    private let tokenService = LiveKitTokenService()
    //private var room: Room?
    @Published private(set) var currentRoom: Room?
    @Published var remoteVideoTrack: VideoTrack?
    @Published var renderTick: Int = 0     // ★ 今回追記：UI再描画トリガ100403
    
    

    // 入室
    func connect(roomName: String, identity: String) async {
        print("🔔 connect() called with roomName=\(roomName), identity=\(identity)")  // ←追加
        connecting = true
        errorMessage = nil
        defer { connecting = false }

        do {
            let res = try await tokenService.fetchToken(room: roomName, identity: identity)

            // 👇ここでトークンを確認
                   print("🔑 LiveKit Token (先頭だけ表示): \(res.token.prefix(60))...")
            
            let room = Room()
            //self.room = room
            self.currentRoom = room
            // room.delegate = self               // ← 重複させない
            room.add(delegate: self)               // ← こちらだけでOK

            // ★変更点：必ず Info.plist の LIVEKIT_URL を使う
            try await room.connect(url: AppConfig.livekitURL, token: res.token)
            
            
            // ★ 置き換え：入室直後に、既存のリモート映像をまとめて購読（LiveKit 1.9）
           
           
            // ★ ここまで置き換え

            // まずはマイクON（権限チェックつき）
            try await ensureMicPermissionThen {
                try await room.localParticipant.setMicrophone(enabled: true)
            }
            self.isMicEnabled = true

            // カメラはデフォルトOFF（必要時にON）
            self.isCamEnabled = false
            
            // ✅ ここに追記
            print("✅ Connected to room: \(room.name)")
            print("👥 Local participant: \(room.localParticipant.identity)")
            print("👥 Remote count: \(room.remoteParticipants.count)")

        } catch {
            self.errorMessage = error.localizedDescription
            print("❌ connect error: \(error)")
        }
    }

    // 退出
    func disconnect() {
        Task {
            if let room = currentRoom {            // ← currentRoom を使う
                await room.disconnect()
            }
            await MainActor.run {
                self.isMicEnabled = false
                self.isCamEnabled = false
                //self.room = nil
                self.currentRoom = nil             // ← currentRoom をクリア
                
            }
        }
    }

    // マイク切替
    func toggleMic() async {
        guard let room = currentRoom else { return }   // ← currentRoom を使う
        do {
            if isMicEnabled {
                try await room.localParticipant.setMicrophone(enabled: false)
                isMicEnabled = false
            } else {
                try await ensureMicPermissionThen {
                    try await room.localParticipant.setMicrophone(enabled: true)
                }
                isMicEnabled = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // カメラ切替
    func toggleCamera() async {
        guard let room = currentRoom else { return }   // ← currentRoom を使う
        do {
            if isCamEnabled {
                try await room.localParticipant.setCamera(enabled: false)
                isCamEnabled = false
            } else {
                try await ensureCameraPermissionThen {
                    try await room.localParticipant.setCamera(enabled: true)
                }
                isCamEnabled = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - 権限

    private func ensureMicPermissionThen(_ block: @escaping () async throws -> Void) async throws {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            try await block()
        case .denied:
            throw NSError(domain: "LiveKit", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "マイクの許可がありません。設定で有効にしてください。"])
        case .undetermined:
            try await withCheckedThrowingContinuation { cont in
                AVAudioSession.sharedInstance().requestRecordPermission { ok in
                    Task {
                        if ok { try await block(); cont.resume() }
                        else {
                            cont.resume(throwing: NSError(domain: "LiveKit", code: 1,
                               userInfo: [NSLocalizedDescriptionKey: "マイクの許可が必要です。"]))
                        }
                    }
                }
            }
        @unknown default:
            try await block()
        }
    }

    private func ensureCameraPermissionThen(_ block: @escaping () async throws -> Void) async throws {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            try await block()
        case .denied, .restricted:
            throw NSError(domain: "LiveKit", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "カメラの許可がありません。設定で有効にしてください。"])
        case .notDetermined:
            let ok = await AVCaptureDevice.requestAccess(for: .video)
            if ok { try await block() }
            else {
                throw NSError(domain: "LiveKit", code: 2,
                              userInfo: [NSLocalizedDescriptionKey: "カメラの許可が必要です。"])
            }
        @unknown default:
            try await block()
        }
    }
}

// （任意）切断などを自動検知したい時
extension LessonCallViewModel: RoomDelegate {
    nonisolated func room(
        _ room: Room,
        didUpdateConnectionState connectionState: ConnectionState,
        from oldState: ConnectionState
    ) {
        if case .disconnected = connectionState {
            Task { @MainActor in
                self.isMicEnabled = false
                self.isCamEnabled = false
                // self.room = nil
                self.currentRoom = nil                // ← currentRoom をクリア
                self.remoteVideoTrack = nil          // ★ 今回追記：相手映像もクリア
                self.renderTick &+= 1                // ★ 今回追記：UIに反映させる100403
                
                
            }
        }
    }
    // ★ 今回追記：リモートのトラック購読が成立したらUI再描画を促す
    nonisolated func room(
        _ room: Room,
        participant: RemoteParticipant,
        didSubscribe track: RemoteTrack,
        publication: RemoteTrackPublication
    ) {
        guard let video = track as? VideoTrack else { return } // ★ 今回追記
        Task { @MainActor in
            self.remoteVideoTrack = video
            //self.objectWillChange.send()  // ★ 今回追記
            self.renderTick &+= 1                    // ★ 今回追記：再描画を確実化100403
            print("📺 didSubscribe VIDEO from \(participant.identity)")  // ★ 今回追記（任意ログ）
        }
    }
    
    // ★ 今回追記：リモートの購読解除でも再描画（入れ替わりに対応）
    nonisolated func room(
        _ room: Room,
        participant: RemoteParticipant,
        didUnsubscribe track: RemoteTrack,
        publication: RemoteTrackPublication
    ) {
        guard let video = track as? VideoTrack else { return } // ★ 今回追記
        Task { @MainActor in
            if self.remoteVideoTrack === video {               // ★ 今回追記
                self.remoteVideoTrack = nil                    // ★ 今回追記
                self.renderTick &+= 1                // ★ 今回追記：再描画を確実化100403
                print("🗑️ didUnsubscribe VIDEO from \(participant.identity)")
            }
        }
    }
    
    // ★ 今回追記：相手が VIDEO を publish した瞬間に「こちらから購読を開始」する
    nonisolated func room(
        _ room: Room,
        participant: RemoteParticipant,
        didPublishTrack publication: RemoteTrackPublication
    ) {
        guard publication.kind == .video else { return }      // ← 映像だけ対象
        Task {
            try? await publication.set(subscribed: true)      // ← 明示的に購読開始
            print("✅ force subscribe video from \(participant.identity)")
            }
        }
    }

