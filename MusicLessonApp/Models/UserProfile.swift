//
//  UserProfile.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/12.
//

// ファイル: Models/UserProfile.swift
import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    let email: String
    var role: String
    var name: String?
    var affiliation: String?
    var course: String?
}
