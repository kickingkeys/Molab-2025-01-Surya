import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            // Background
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            // Logo and Title
            VStack(spacing: 8) {
                Image("AppIcon") // We'll need to add this to assets
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                
                Text("thoughtsort")
                    .font(.editorialNewRegular(size: 32))
                    .foregroundColor(.black)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SplashView()
} 