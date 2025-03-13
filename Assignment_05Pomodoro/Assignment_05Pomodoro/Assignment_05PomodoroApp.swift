import SwiftUI
import AVFoundation

@main
struct Assignment_05PomodoroApp: App {
    @State private var pomodoroModel = PomodoroModel()
    
    init() {
        // Setup audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Notification observers for audio interruptions
            setupAudioInterruptionHandling()
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func setupAudioInterruptionHandling() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main) { notification in
                
                if let userInfo = notification.userInfo,
                   let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                   let type = AVAudioSession.InterruptionType(rawValue: typeValue) {
                    
                    if type == .began {
                        // Interruption began, pause playback
                        self.pomodoroModel.pause()
                    } else if type == .ended {
                        if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                           AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                            // Only resume if it was active before
                            if self.pomodoroModel.isActive {
                                self.pomodoroModel.start()
                                self.pomodoroModel.playAudioForCurrentSession()
                            }
                        }
                    }
                }
            }
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    TimerView(model: pomodoroModel)
                        .navigationTitle("Pomodoro Timer")
                }
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
                
                NavigationView {
                    MusicSelectionView(model: pomodoroModel)
                        .navigationTitle("Music")
                }
                .tabItem {
                    Label("Music", systemImage: "music.note")
                }
            }
            .accentColor(Color("AccentOrange"))
        }
    }
}
