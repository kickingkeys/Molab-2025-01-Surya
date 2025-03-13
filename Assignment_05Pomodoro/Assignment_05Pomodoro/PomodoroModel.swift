import Foundation
import AVFoundation
import SwiftUI

@Observable
class PomodoroModel {
    // Timer settings
    var focusTime: Int = 25 * 60  // 25 minutes in seconds
    var shortBreakTime: Int = 5 * 60  // 5 minutes
    var longBreakTime: Int = 15 * 60  // 15 minutes
    var sessionsBeforeLongBreak: Int = 4
    
    // Current state
    var timeRemaining: Int = 25 * 60
    var isActive: Bool = false
    var currentSession: SessionType = .focus
    var completedSessions: Int = 0
    var timer: Timer?
    
    // Audio player
    var audioPlayer: AVAudioPlayer?
    var focusAudioName: String = "focus_ambient"
    var breakAudioName: String = "break_relax"
    var notificationSoundName: String = "session_chime"
    var notificationPlayer: AVAudioPlayer?
    
    // Error states
    var audioError: Bool = false
    
    enum SessionType {
        case focus
        case shortBreak
        case longBreak
    }
    
    // Start the timer
    func start() {
        isActive = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, self.isActive else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.playNotificationSound()
                self.moveToNextSession()
            }
        }
    }
    
    // Pause the timer
    func pause() {
        isActive = false
        timer?.invalidate()
    }
    
    // Reset the current session
    func reset() {
        pause()
        setTimeBasedOnSessionType()
    }
    
    // Skip to the next session
    func skip() {
        moveToNextSession()
    }
    
    // Move to the next session in the Pomodoro cycle
    private func moveToNextSession() {
        pause()
        
        switch currentSession {
        case .focus:
            completedSessions += 1
            
            if completedSessions % sessionsBeforeLongBreak == 0 {
                currentSession = .longBreak
            } else {
                currentSession = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentSession = .focus
        }
        
        setTimeBasedOnSessionType()
        start() // Auto-start next session and play audio
    }
    
    // Set the time remaining based on the current session type
    private func setTimeBasedOnSessionType() {
        switch currentSession {
        case .focus:
            timeRemaining = focusTime
        case .shortBreak:
            timeRemaining = shortBreakTime
        case .longBreak:
            timeRemaining = longBreakTime
        }
    }
    
    // Play notification sound
    func playNotificationSound() {
        if let path = Bundle.main.path(forResource: notificationSoundName, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                notificationPlayer = try AVAudioPlayer(contentsOf: url)
                notificationPlayer?.play()
                audioError = false
            } catch {
                print("Could not play notification sound: \(error)")
                audioError = true
            }
        } else {
            print("Notification sound file not found: \(notificationSoundName).mp3")
            audioError = true
        }
    }
    
    // Play the appropriate audio for the current session
    func playAudioForCurrentSession() {
        let audioName: String
        
        switch currentSession {
        case .focus:
            audioName = focusAudioName
        case .shortBreak, .longBreak:
            audioName = breakAudioName
        }
        
        if let path = Bundle.main.path(forResource: audioName, ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.play()
                audioError = false
            } catch {
                print("Could not play audio file: \(error)")
                audioError = true
            }
        } else {
            print("Audio file not found: \(audioName).mp3")
            audioError = true
        }
    }
    
    // Stop any currently playing audio
    func stopAudio() {
        audioPlayer?.stop()
    }
    
    // Format seconds into a MM:SS string
    func formatTime() -> String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // Clean up resources when deallocated
    deinit {
        timer?.invalidate()
        stopAudio()
        notificationPlayer?.stop()
    }
}
