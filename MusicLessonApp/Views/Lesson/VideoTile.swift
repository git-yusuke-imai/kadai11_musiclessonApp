//
//  VideoTile.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/21.
//

// Views/Lesson/VideoTile.swift
import SwiftUI
import LiveKit

/// LiveKit の VideoTrack を表示するシンプルな SwiftUI ラッパー
struct VideoTile: UIViewRepresentable {
    let track: VideoTrack?

    func makeUIView(context: Context) -> VideoView {
        let v = VideoView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }

    func updateUIView(_ uiView: VideoView, context: Context) {
        uiView.track = track
    }
}
