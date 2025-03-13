
import SwiftUI

struct MiniPlayerView: View {
    @EnvironmentObject var appState: AppState
    @State private var showPlayer = false
    
    var body: some View {
        HStack {
            // Mini CD icon
            Image("cd_dvd_PNG9064")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .rotationEffect(appState.isPlaying ? .degrees(360) : .degrees(0))
                .animation(appState.isPlaying ? Animation.linear(duration: 10).repeatForever(autoreverses: false) : .default, value: appState.isPlaying)
            
            // Song info
            VStack(alignment: .leading) {
                Text(appState.currentSong)
                    .font(.footnote)
                    .lineLimit(1)
                
                Text(appState.currentArtist)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Play/Pause button
            Button(action: {
                appState.isPlaying.toggle()
            }) {
                Image(systemName: appState.isPlaying ? "pause.fill" : "play.fill")
                    .padding(.horizontal)
            }
        }
        .padding(.horizontal)
        .onTapGesture {
            if appState.currentlyPlayingIndex != nil {
                showPlayer = true
            }
        }
        .navigationDestination(isPresented: $showPlayer) {
            if let index = appState.currentlyPlayingIndex {
                PlayerView(cdIndex: index)
            }
        }
    }
}
