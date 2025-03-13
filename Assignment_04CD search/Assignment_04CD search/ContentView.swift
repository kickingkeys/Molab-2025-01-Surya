//
//  ContentView.swift
//  Assignment_04CD search
//
//  Created by Surya Narreddi on 24/02/25.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    
    var body: some View {
        NavigationStack {
            ZStack {
                CDCollectionView()
                
                // Mini player if a song is playing
                if appState.currentlyPlayingIndex != nil {
                    MiniPlayerView()
                        .frame(height: 60)
                        .background(Color.gray.opacity(0.8))
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 40)
                }
            }
            .environmentObject(appState)
            .navigationTitle("scratch cd · ✧ ·")
        }
    }
}
#Preview {
    ContentView()
}
