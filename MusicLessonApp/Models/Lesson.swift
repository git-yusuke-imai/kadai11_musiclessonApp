//
//  Lesson.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
//

import Foundation

struct Lesson: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let text: String
    let audioFileName: String? // Bundle内 m4a 等
    let sheetImageName: String?   // ← 追加
}

enum LessonData {
    static let all: [Lesson] = [
        .init(title: "コード表", text: "コード進行", audioFileName: "lesson1", sheetImageName: "lesson1"),
        .init(title: "スケール練習", text: "Cメジャー", audioFileName: "lesson2", sheetImageName: "lesson2"),
        .init(title: "簡単なフレーズ", text: "8小節", audioFileName: "lesson3", sheetImageName: "lesson3")
    ]
}

