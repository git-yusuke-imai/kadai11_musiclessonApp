//
//  AudioLevelMeter.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/09.
//

import Foundation
import AVFoundation
import Combine
import Accelerate   // ← これを追加

@MainActor
final class AudioLevelMeter: ObservableObject {
    @Published var level: Float = 0.0   // 0.0 ... 1.0

    private let engine = AVAudioEngine()
    private let session = AVAudioSession.sharedInstance()
    private var isRunning = false

    func start() async {
        guard !isRunning else { return }
        do {
            // LiveKit と両立しやすい設定
            try session.setCategory(.playAndRecord, mode: .voiceChat, options: [.allowBluetooth, .defaultToSpeaker])
            try session.setActive(true)

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)

            // できるだけ軽く
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                guard let ch = buffer.floatChannelData?.pointee else { return }
                let frameCount = Int(buffer.frameLength)

                // RMS → dB → 0..1 正規化（-60dBを底とする）
                var sum: Float = 0
                vDSP_measqv(ch, 1, &sum, vDSP_Length(frameCount))
                let rms = sqrtf(sum)
                let db = 20 * log10f(max(rms, 1e-7))
                let norm = max(0, min(1, (db + 60) / 60)) // -60dB..0dB → 0..1

                DispatchQueue.main.async {
                    self?.level = norm
                }
            }

            try engine.start()
            isRunning = true
        } catch {
            print("AudioLevelMeter start error:", error)
        }
    }

    func stop() {
        guard isRunning else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false
        level = 0
    }
}
