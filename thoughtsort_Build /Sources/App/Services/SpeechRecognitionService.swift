import Foundation
import Speech
import SwiftUI

class SpeechRecognitionService: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var error: Error?
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    break
                case .denied:
                    self?.error = SpeechRecognitionError.notAuthorized
                case .restricted:
                    self?.error = SpeechRecognitionError.restricted
                case .notDetermined:
                    self?.error = SpeechRecognitionError.notDetermined
                @unknown default:
                    self?.error = SpeechRecognitionError.unknown
                }
            }
        }
    }
    
    func startRecording() {
        // Cancel any ongoing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            self.error = error
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            self.error = SpeechRecognitionError.requestCreationFailed
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Configure microphone input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            self.error = error
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                self?.transcribedText = result.bestTranscription.formattedString
            }
            
            if error != nil {
                self?.stopRecording()
                self?.error = error
            }
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        isRecording = false
        
        // Reset audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

enum SpeechRecognitionError: LocalizedError {
    case notAuthorized
    case restricted
    case notDetermined
    case requestCreationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition not authorized"
        case .restricted:
            return "Speech recognition restricted on this device"
        case .notDetermined:
            return "Speech recognition authorization not determined"
        case .requestCreationFailed:
            return "Could not create speech recognition request"
        case .unknown:
            return "Unknown speech recognition error"
        }
    }
} 