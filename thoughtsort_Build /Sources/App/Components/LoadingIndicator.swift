import SwiftUI

struct LoadingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.accentBrand.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .scaleEffect(isAnimating ? 1 : 0.5)
                    .opacity(isAnimating ? 0 : 1)
                    .animation(
                        .easeInOut(duration: 1)
                        .repeatForever(autoreverses: false)
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingIndicator()
        .frame(width: 100, height: 100)
        .background(Color.black.opacity(0.1))
} 