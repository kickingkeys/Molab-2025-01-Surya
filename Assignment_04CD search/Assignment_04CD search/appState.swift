//
//  appState.swift
//  Assignment_04CD search
//
//  Created by Surya Narreddi on 24/02/25.
//

import SwiftUI
import AVFoundation

class AppState: ObservableObject {
    @Published var selectedCDIndex: Int? = nil
    @Published var isPlaying: Bool = false
    @Published var currentSong: String = ""
    @Published var currentArtist: String = ""
    @Published var cdPositions: [CGPoint] = []
    @Published var cdDrawings: [Int: Path] = [:]
    @Published var currentlyPlayingIndex: Int? = nil
    @Published var isDrawMode: Bool = true // true for draw, false for erase
    
    // Update with your actual song files and artists
    let songs = [
        ("The Spins", "Mac Miller"),
        ("Wi Ing Wi Ing", "HYUKOH"),
        ("Marejada Feliz", "Unknown Artist"),
        ("Want To Love (Just Raw)", "Aloboi"),
        ("Hey Jude (Remastered 2015)", "The Beatles")
    ]
    
    // File names for the audio files
    let songFiles = [
        "The Spins.mp3",
        "[Official Audio] HYUKOH...잉 (Wi Ing Wi Ing).mp3",
        "Marejada Feliz.mp3",
        "Aloboi - Want To Love (Just Raw).mp3",
        "Hey Jude (Remastered 2015).mp3"
    ]
    
    init() {
        // Initialize random CD positions
        resetCDPositions()
    }
    
    func resetCDPositions() {
        cdPositions = (0..<5).map { _ in
            CGPoint(
                x: CGFloat.random(in: 50...300),
                y: CGFloat.random(in: 100...600)
            )
        }
    }
}
