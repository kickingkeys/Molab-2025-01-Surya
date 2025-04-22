import SwiftUI

struct ThemeColors {
    static let background = Color(hex: "EFF0EA")
    static let accent = Color(hex: "ED682B")
    static let textDark = Color(hex: "434343")
    static let textLight = Color(hex: "A9A9A7")
    static let inputBackground = Color(hex: "DCDDD7")
    static let buttonLight = Color(hex: "EFDCCD")
    static let white = Color(hex: "FFFFFF")
    static let black = Color(hex: "000000")
}

struct ThemeTypography {
    // Editorial New fonts for headings
    static let titleLarge = Font.custom("PPEditorialNew-Regular", size: 28)
    static let titleMedium = Font.custom("PPEditorialNew-Regular", size: 24)
    static let titleSmall = Font.custom("PPEditorialNew-Regular", size: 20)
    
    // Neue Montreal fonts for body text
    static let bodyLarge = Font.custom("PPNeueMontreal-Medium", size: 16)
    static let bodyRegular = Font.custom("PPNeueMontreal-Book", size: 14)
    static let bodySmall = Font.custom("PPNeueMontreal-Book", size: 12)
    
    // Special text styles
    static let caption = Font.custom("PPNeueMontreal-Medium", size: 12)
    static let button = Font.custom("PPNeueMontreal-Medium", size: 16)
    static let tabLabel = Font.custom("PPNeueMontreal-Medium", size: 12)
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
