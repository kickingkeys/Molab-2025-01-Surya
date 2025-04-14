import SwiftUI

struct ConfettiView: View {
    @State private var isAnimating = false
    let colors: [Color] = [
        .accentBrand, // Brand orange
        Color(hex: "EFDCCD"), // Cream
        Color(hex: "DCDDD7")  // Light gray
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<50) { index in
                ConfettiPiece(
                    color: colors[index % colors.count],
                    size: CGFloat.random(in: 5...10),
                    position: randomPosition(in: geometry.size),
                    rotation: Double.random(in: 0...360)
                )
                .offset(y: isAnimating ? geometry.size.height : -50)
                .opacity(isAnimating ? 0 : 1)
                .animation(
                    .easeOut(duration: Double.random(in: 1.5...2.5))
                    .delay(Double.random(in: 0...0.5)),
                    value: isAnimating
                )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func randomPosition(in size: CGSize) -> CGPoint {
        CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: -50...0)
        )
    }
}

struct ConfettiPiece: View {
    let color: Color
    let size: CGFloat
    let position: CGPoint
    let rotation: Double
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .position(position)
            .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    ConfettiView()
        .frame(height: 300)
        .background(Color.black.opacity(0.1))
} 