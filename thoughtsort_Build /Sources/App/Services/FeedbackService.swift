import SwiftUI
import UIKit

class FeedbackService: ObservableObject {
    static let shared = FeedbackService()
    
    // Haptic feedback generators
    private let mediumImpactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let lightImpactGenerator = UIImpactFeedbackGenerator(style: .light)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        // Pre-prepare generators for lower latency
        mediumImpactGenerator.prepare()
        lightImpactGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Haptic Feedback
    
    func triggerTaskCompletionHaptic() {
        mediumImpactGenerator.impactOccurred()
    }
    
    func triggerButtonPressHaptic() {
        lightImpactGenerator.impactOccurred()
    }
    
    func triggerSelectionHaptic() {
        selectionGenerator.selectionChanged()
    }
    
    // MARK: - Animation Constants
    
    struct Animation {
        static let buttonPress = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.6)
        static let taskCompletion = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let listTransition = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let emptyState = SwiftUI.Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)
    }
    
    struct Scale {
        static let buttonPress: CGFloat = 0.96
        static let taskCompletion: CGFloat = 1.05
    }
    
    struct Duration {
        static let confetti: TimeInterval = 2.0
        static let buttonPress: TimeInterval = 0.2
        static let taskCompletion: TimeInterval = 0.3
    }
} 