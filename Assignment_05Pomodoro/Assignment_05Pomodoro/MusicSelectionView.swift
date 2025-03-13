//
//  SwiftUI View.swift
//  Assignment_05Pomodoro
//
//  Created by Surya Narreddi on 13/03/25.
//

import SwiftUI

struct MusicSelectionView: View {
    @Bindable var model: PomodoroModel
    @Environment(\.dismiss) private var dismiss
    
    // Simplified options for music selection
    let focusSounds = ["Focus Ambient"]
    let breakSounds = ["Break Relax"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 25) {
                    // Focus sounds
                    Section {
                        Text("Focus Session Sounds")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TextColor"))
                            .padding(.bottom, 5)
                        
                        ForEach(focusSounds, id: \.self) { sound in
                            SoundSelectionRow(
                                title: sound,
                                isSelected: model.focusAudioName == convertToFileName(sound),
                                action: {
                                    model.focusAudioName = convertToFileName(sound)
                                    if model.currentSession == .focus {
                                        model.stopAudio()
                                        model.playAudioForCurrentSession()
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color("TextColor").opacity(0.05), radius: 5)
                    )
                    
                    // Break sounds
                    Section {
                        Text("Break Session Sounds")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Color("TextColor"))
                            .padding(.bottom, 5)
                        
                        ForEach(breakSounds, id: \.self) { sound in
                            SoundSelectionRow(
                                title: sound,
                                isSelected: model.breakAudioName == convertToFileName(sound),
                                action: {
                                    model.breakAudioName = convertToFileName(sound)
                                    
                                    if model.currentSession == .shortBreak || model.currentSession == .longBreak {
                                        model.stopAudio()
                                        model.playAudioForCurrentSession()
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color("TextColor").opacity(0.05), radius: 5)
                    )
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Music Selection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("AccentOrange"))
                }
            }
        }
    }
    
    // Helper to convert display names to file names
    private func convertToFileName(_ displayName: String) -> String {
        return displayName.lowercased().replacingOccurrences(of: " ", with: "_")
    }
}

struct SoundSelectionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("AccentOrange"))
                }
            }
            .padding(.vertical, 8)
        }
    }
}

struct SoundSelectionRow_Previews: PreviewProvider {
    static var previews: some View {
        SoundSelectionRow(title: "Sample Sound", isSelected: true, action: {})
    }
}
