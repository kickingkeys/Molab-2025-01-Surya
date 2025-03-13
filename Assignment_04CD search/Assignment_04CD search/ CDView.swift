//
//   CDView.swift
//  Assignment_04CD search
//
//  Created by Surya Narreddi on 24/02/25.
//

import SwiftUI

struct CDView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPlayer = false
    let index: Int
    
    var body: some View {
        ZStack {
            // Use your actual CD image
            Image("cd_dvd_PNG9064")
                .resizable()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay(
                    // Display drawing on CD if it exists
                    appState.cdDrawings[index] != nil ?
                        appState.cdDrawings[index]!
                            .stroke(Color.black, lineWidth: 2)
                            .frame(width: 120, height: 120)
                    : nil
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // Drawing functionality
                            if appState.selectedCDIndex == index {
                                var path = appState.cdDrawings[index] ?? Path()
                                
                                if appState.isDrawMode {
                                    // Draw mode
                                    if path.isEmpty {
                                        path.move(to: value.location)
                                    } else {
                                        path.addLine(to: value.location)
                                    }
                                } else {
                                    // Erase mode - implement by creating a new path
                                    path = Path()
                                }
                                
                                appState.cdDrawings[index] = path
                            }
                        }
                )
                .onTapGesture(count: 1) {
                    // Select CD for drawing
                    appState.selectedCDIndex = index
                }
                .onTapGesture(count: 2) {
                    // Set as currently playing
                    appState.currentlyPlayingIndex = index
                    
                    // Set song info
                    let songInfo = appState.songs[index % appState.songs.count]
                    appState.currentSong = songInfo.0
                    appState.currentArtist = songInfo.1
                    appState.isPlaying = true
                    
                    // Navigate to player
                    showPlayer = true
                }
                .navigationDestination(isPresented: $showPlayer) {
                    PlayerView(cdIndex: index)
                }
        }
        
        
        
    }
}
