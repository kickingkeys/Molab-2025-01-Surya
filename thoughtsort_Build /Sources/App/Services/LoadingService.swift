import SwiftUI

enum LoadingState: Equatable {
    case idle
    case loading(String)
    case success
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    var message: String? {
        switch self {
        case .loading(let message):
            return message
        case .error(let message):
            return message
        default:
            return nil
        }
    }
}

@MainActor
class LoadingService: ObservableObject {
    static let shared = LoadingService()
    
    @Published var state: LoadingState = .idle
    @Published var isOverlayVisible = false
    
    private init() {}
    
    func startLoading(_ message: String = "Loading...") {
        state = .loading(message)
        isOverlayVisible = true
    }
    
    func stopLoading() {
        state = .idle
        isOverlayVisible = false
    }
    
    func showError(_ message: String) {
        state = .error(message)
        isOverlayVisible = true
    }
    
    func showSuccess() {
        state = .success
        isOverlayVisible = false
    }
}

struct LoadingOverlay: View {
    @StateObject private var loadingService = LoadingService.shared
    
    var body: some View {
        ZStack {
            if loadingService.isOverlayVisible {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 16) {
                    if case .loading = loadingService.state {
                        LoadingIndicator()
                            .frame(width: 48, height: 48)
                    }
                    
                    if let message = loadingService.state.message {
                        Text(message)
                            .font(.montrealMedium(size: 16))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(24)
                .background(Color.accentBrand)
                .cornerRadius(16)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: loadingService.isOverlayVisible)
    }
} 