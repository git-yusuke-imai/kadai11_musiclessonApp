//
//  LiveKitTokenService.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/20.
//

import Foundation
import Supabase

struct LiveKitTokenResponse: Decodable {
    let token: String
    let host: String?   // 返していれば使う
}

final class LiveKitTokenService {
    private let client = SupabaseClientProvider.shared
    private let functionURL = URL(string: "https://lkiccpjcehpqwbmyghsi.functions.supabase.co/livekit-token")!

    /// SupabaseのセッショントークンをAuthorizationに乗せてEdge Functionを叩く
    func fetchToken(room: String, identity: String) async throws -> LiveKitTokenResponse {
        // 現在のセッションJWT（access_token）を取得
        let session = try await client.auth.session
        let jwt = session.accessToken 

        var comps = URLComponents(url: functionURL, resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            .init(name: "room", value: room),
            .init(name: "identity", value: identity),
        ]
        var req = URLRequest(url: comps.url!)
        req.httpMethod = "GET"
        req.addValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let text = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "LiveKitToken", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: text])
        }
        return try JSONDecoder().decode(LiveKitTokenResponse.self, from: data)
    }
}
