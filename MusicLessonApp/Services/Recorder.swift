//
//  Recorder.swift
//  MusicLessonApp
//
//  Created by Yuusuke Imai on 2025/09/03.
//

import AVFoundation

final class Recorder: ObservableObject {
    @Published var isRecording = false
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    private var url: URL {
        let filename = "practice.m4a"
        #if os(macOS)
        return FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        #else
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return dir.appendingPathComponent(filename)
        #endif
    }

    func requestPermission(completion: @escaping (Bool)->Void) {
        #if os(iOS)
        AVAudioSession.sharedInstance().requestRecordPermission { ok in
            completion(ok)
        }
        #elseif os(macOS)
        // macOS では AVAudioSession がないため、録音許可は常に true 扱いにする
        completion(true)
        #endif
    }

    func start() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("AVAudioSession error:", error)
        }
        #endif

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            isRecording = true
        } catch {
            print("record start error:", error)
        }
    }


    func stop() {
        recorder?.stop()
        isRecording = false
    }

    func playBack() {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("playback error:", error)
        }
    }
}
