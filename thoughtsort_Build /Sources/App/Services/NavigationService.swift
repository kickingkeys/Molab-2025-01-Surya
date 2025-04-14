import SwiftUI

enum AppRoute: Equatable {
    case splash
    case login
    case signUp
    case home
    case archive
    case taskList(TaskList)
    case settings
    
    static func == (lhs: AppRoute, rhs: AppRoute) -> Bool {
        switch (lhs, rhs) {
        case (.splash, .splash),
             (.login, .login),
             (.signUp, .signUp),
             (.home, .home),
             (.archive, .archive),
             (.settings, .settings):
            return true
        case (.taskList(let lhsList), .taskList(let rhsList)):
            return lhsList.id == rhsList.id
        default:
            return false
        }
    }
}

@MainActor
class NavigationService: ObservableObject {
    static let shared = NavigationService()
    
    @Published var currentRoute: AppRoute = .splash
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: AppRoute?
    @Published var presentedAlert: AlertItem?
    
    private init() {}
    
    func navigate(to route: AppRoute) {
        navigationPath.append(route)
        currentRoute = route
    }
    
    func navigateBack() {
        _ = navigationPath.removeLast()
        if let lastRoute = navigationPath.last as? AppRoute {
            currentRoute = lastRoute
        }
    }
    
    func navigateToRoot() {
        navigationPath.removeLast(navigationPath.count)
        currentRoute = .home
    }
    
    func presentSheet(_ route: AppRoute) {
        presentedSheet = route
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func showAlert(_ alert: AlertItem) {
        presentedAlert = alert
    }
    
    func dismissAlert() {
        presentedAlert = nil
    }
}

struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButton: AlertButton?
    let secondaryButton: AlertButton?
    
    struct AlertButton {
        let title: String
        let role: ButtonRole?
        let action: () -> Void
        
        init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void = {}) {
            self.title = title
            self.role = role
            self.action = action
        }
    }
    
    init(
        title: String,
        message: String,
        primaryButton: AlertButton? = AlertButton(title: "OK"),
        secondaryButton: AlertButton? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
} 