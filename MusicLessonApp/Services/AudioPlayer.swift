//
//  AudioPlayer.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
//


import AVFoundation

final class AudioPlayer: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0

    private var player: AVAudioPlayer?
    private var tick: Timer?

    func play(named: String, loop: Bool = false, rate: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: named, withExtension: "m4a") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            #if os(iOS)
            player?.enableRate = true
            player?.rate = max(0.5, min(rate, 2.0))
            #endif
            player?.numberOfLoops = loop ? -1 : 0
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            duration = player?.duration ?? 0
            startTick()
        } catch {
            print("Audio play error:", error)
        }
    }

    func togglePause() {
        guard let p = player else { return }
        if p.isPlaying { p.pause(); isPlaying = false } else { p.play(); isPlaying = true }
    }

    func stop() {
        player?.stop()
        isPlaying = false
        currentTime = 0
        stopTick()
    }

    func seek(to time: TimeInterval) {
        guard let p = player else { return }
        p.currentTime = max(0, min(time, p.duration))
        currentTime = p.currentTime
        if isPlaying { p.play() }
    }

    private func startTick() {
        stopTick()
        tick = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self, let p = self.player else { return }
            self.currentTime = p.currentTime
            self.duration = p.duration
            if !p.isPlaying { self.isPlaying = false; self.stopTick() }
        }
    }
    private func stopTick() { tick?.invalidate(); tick = nil }
}
