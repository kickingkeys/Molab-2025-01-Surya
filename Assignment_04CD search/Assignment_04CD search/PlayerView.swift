//
//  PlayerView.swift
//  Assignment_04CD search
//
//  Created by Surya Narreddi on 24/02/25.
//

import SwiftUI
import AVFoundation

struct PlayerView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let cdIndex: Int
    
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack {
            Spacer()
            
            // CD with any drawings
            ZStack {
                Image("cd_dvd_PNG9064")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
                    .rotationEffect(appState.isPlaying ? .degrees(360) : .degrees(0))
                    .animation(appState.isPlaying ? Animation.linear(duration: 10).repeatForever(autoreverses: false) : .default, value: appState.isPlaying)
                
                if let drawing = appState.cdDrawings[cdIndex] {
                    drawing
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 200, height: 200)
                        .rotationEffect(appState.isPlaying ? .degrees(360) : .degrees(0))
                        .animation(appState.isPlaying ? Animation.linear(duration: 10).repeatForever(autoreverses: false) : .default, value: appState.isPlaying)
                }
            }
            
            Spacer()
            
            // Song info
            Text(appState.currentSong)
                .font(.title)
                .padding(.bottom, 5)
            
            Text(appState.currentArtist)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 40)
            
            // Playback controls
            HStack(spacing: 50) {
                Button(action: {
                    // Previous song logic
                    let newIndex = (cdIndex - 1 + 5) % 5
                    appState.currentlyPlayingIndex = newIndex
                    let songInfo = appState.songs[newIndex % appState.songs.count]
                    appState.currentSong = songInfo.0
                    appState.currentArtist = songInfo.1
                    
                    // Play the previous song
                    playAudio(index: newIndex)
                    
                    // Navigate back and then to new player
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                }
                
                Button(action: {
                    appState.isPlaying.toggle()
                    
                    if appState.isPlaying {
                        audioPlayer?.play()
                    } else {
                        audioPlayer?.pause()
                    }
                }) {
                    Image(systemName: appState.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                }
                
                Button(action: {
                    // Next song logic
                    let newIndex = (cdIndex + 1) % 5
                    appState.currentlyPlayingIndex = newIndex
                    let songInfo = appState.songs[newIndex % appState.songs.count]
                    appState.currentSong = songInfo.0
                    appState.currentArtist = songInfo.1
                    
                    // Play the next song
                    playAudio(index: newIndex)
                    
                    // Navigate back and then to new player
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(false)
        .onAppear {
            playAudio(index: cdIndex)
        }
    }
    
    func playAudio(index: Int) {
        let songFile = appState.songFiles[index]
        
        guard let url = Bundle.main.url(forResource: songFile.replacingOccurrences(of: ".mp3", with: ""), withExtension: "mp3") else {
            print("Could not find audio file: \(songFile)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if appState.isPlaying {
                audioPlayer?.play()
            }
        } catch {
            print("Could not play audio: \(error)")
        }
    }
}
