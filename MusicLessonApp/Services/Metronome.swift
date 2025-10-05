//
//  Metronome.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
//

import AVFoundation

final class Metronome: ObservableObject {
    @Published var bpm: Double = 80
    private var timer: DispatchSourceTimer?
    private var audioID: SystemSoundID = 1104 // クリック音（iOS系統音）

    func start() {
        stop()
        let interval = 60.0 / bpm
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now(), repeating: interval)
        t.setEventHandler { AudioServicesPlaySystemSound(self.audioID) }
        t.resume()
        timer = t
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }
}
