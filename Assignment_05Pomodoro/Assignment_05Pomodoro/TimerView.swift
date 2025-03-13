//
//  TimerView.swift
//  Assignment_05Pomodoro
//
//  Created by Surya Narreddi on 13/03/25.
//

import SwiftUI

struct TimerView: View {
    @Bindable var model: PomodoroModel
    @State private var showMusicSelection = false
    
    var body: some View {
        ZStack {
            // Background
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Session indicator
                Text(sessionTitle)
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                
                // Timer circle
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color("AccentOrange").opacity(0.2), lineWidth: 6)
                        .frame(width: 250, height: 250)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color("AccentOrange"), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    
                    // Time remaining
                    Text(model.formatTime())
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(Color("TextColor"))
                }
                
                // Control buttons
                HStack(spacing: 60) {
                    // Reset button
                    Button(action: {
                        model.reset()
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title)
                            .foregroundColor(Color("AccentOrange"))
                    }
                    
                    // Play/Pause button
                    Button(action: {
                        if model.isActive {
                            model.pause()
                        } else {
                            model.start()
                            model.playAudioForCurrentSession() // Play audio when starting
                        }
                    }) {
                        Circle()
                            .fill(Color("AccentOrange"))
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: model.isActive ? "pause.fill" : "play.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            )
                    }
                    
                    // Skip button
                    Button(action: {
                        model.skip()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                            .foregroundColor(Color("AccentOrange"))
                    }
                }
                
                // Session dots
                HStack(spacing: 12) {
                    ForEach(0..<model.sessionsBeforeLongBreak, id: \.self) { index in
                        Circle()
                            .fill(index < model.completedSessions % model.sessionsBeforeLongBreak ||
                                  (index == 0 && model.completedSessions % model.sessionsBeforeLongBreak == 0 && model.completedSessions > 0) ?
                                  Color("AccentOrange") : Color("AccentOrange").opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 20)
                
                // Music selection button
                Button(action: {
                    showMusicSelection = true
                }) {
                    HStack {
                        Image(systemName: "music.note")
                        Text("Music Selection")
                    }
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Color("AccentOrange"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("AccentOrange"), lineWidth: 1)
                    )
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMusicSelection) {
            MusicSelectionView(model: model)
        }
    }
    
    // Helper to get the current session title
    private var sessionTitle: String {
        switch model.currentSession {
        case .focus:
            return "Focus Time"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }
    
    // Helper to calculate the progress for the circle
    private var progress: CGFloat {
        switch model.currentSession {
        case .focus:
            return 1.0 - CGFloat(model.timeRemaining) / CGFloat(model.focusTime)
        case .shortBreak:
            return 1.0 - CGFloat(model.timeRemaining) / CGFloat(model.shortBreakTime)
        case .longBreak:
            return 1.0 - CGFloat(model.timeRemaining) / CGFloat(model.longBreakTime)
        }
    }
}



