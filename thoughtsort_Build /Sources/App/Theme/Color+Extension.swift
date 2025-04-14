import SwiftUI

extension Color {
    // Background Colors
    static let backgroundPrimary = Color(red: 0.94, green: 0.94, blue: 0.92)
    static let inputBackground = Color(red: 0.86, green: 0.87, blue: 0.84)
    
    // Text Colors
    static let textPrimary = Color(red: 0.26, green: 0.26, blue: 0.26)
    static let textSecondary = Color(red: 0.66, green: 0.66, blue: 0.65)
    static let textTertiary = Color(red: 0.31, green: 0.31, blue: 0.30)
    
    // Brand Colors
    static let accentBrand = Color(hex: "ED682B") // Orange brand color
    
    // Shadow Colors
    static let shadowColor = Color(red: 0.89, green: 0.90, blue: 0.91, opacity: 0.24)
    
    // Helper initializer for hex colors
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