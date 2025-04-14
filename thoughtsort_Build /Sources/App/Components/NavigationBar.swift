import SwiftUI

struct NavigationBar: View {
    let title: String
    let showBackButton: Bool
    let action: (() -> Void)?
    
    init(title: String = "", showBackButton: Bool = true, action: (() -> Void)? = nil) {
        self.title = title
        self.showBackButton = showBackButton
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if showBackButton {
                Button(action: { action?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.textPrimary)
                }
            }
            
            if !title.isEmpty {
                Text(title)
                    .font(.editorialNewRegular(size: 20))
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 20)
        .background(Color.backgroundPrimary)
    }
}

#Preview {
    NavigationBar(title: "Sample Title") {
        print("Back button tapped")
    }
} 