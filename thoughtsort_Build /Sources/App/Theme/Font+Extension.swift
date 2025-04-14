import SwiftUI

extension Font {
    // Title Text Styles using PP Editorial New
    static func editorialNewRegular(size: CGFloat) -> Font {
        .custom("PPEditorialNew-Regular", size: size)
    }
    
    static func editorialNewUltralight(size: CGFloat) -> Font {
        .custom("PPEditorialNew-Ultralight", size: size)
    }
    
    static func editorialNewUltrabold(size: CGFloat) -> Font {
        .custom("PPEditorialNew-Ultrabold", size: size)
    }
    
    // Body Text Styles using PP Neue Montreal
    static func neueMontreal(size: CGFloat) -> Font {
        .custom("PPNeueMontreal-Book", size: size)
    }
    
    static func montrealMedium(size: CGFloat) -> Font {
        .custom("PPNeueMontreal-Medium", size: size)
    }
    
    static func montrealBold(size: CGFloat) -> Font {
        .custom("PPNeueMontreal-Bold", size: size)
    }
    
    // Predefined text styles
    static let splashTitle = editorialNewRegular(size: 32)
    static let largeTitle = editorialNewRegular(size: 28)
    static let title1 = editorialNewRegular(size: 24)
    static let title2 = editorialNewRegular(size: 20)
    static let body = neueMontreal(size: 16)
    static let bodyMedium = montrealMedium(size: 16)
    static let caption = neueMontreal(size: 14)
} 