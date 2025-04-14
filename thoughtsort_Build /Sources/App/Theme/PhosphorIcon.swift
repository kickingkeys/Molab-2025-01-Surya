import SwiftUI

enum PhosphorIcon: String {
    // Tab Bar Icons
    case house = "house"
    case archiveBox = "archive-box"
    
    // Action Icons
    case microphone = "microphone"
    case magicWand = "magic-wand"
    case arrowLeft = "arrow-left"
    
    var iconName: String {
        return "ph.\(rawValue)"
    }
}

struct PhosphorIconView: View {
    let icon: PhosphorIcon
    let size: CGFloat
    let color: Color
    let weight: IconWeight
    
    enum IconWeight: String {
        case regular
        case bold
        case fill
    }
    
    init(
        _ icon: PhosphorIcon,
        size: CGFloat = 24,
        color: Color = .textPrimary,
        weight: IconWeight = .regular
    ) {
        self.icon = icon
        self.size = size
        self.color = color
        self.weight = weight
    }
    
    var body: some View {
        Image(icon.iconName + (weight == .fill ? "-fill" : ""))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundColor(color)
    }
} 