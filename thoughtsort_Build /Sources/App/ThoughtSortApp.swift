import SwiftUI
import FirebaseCore

@main
struct ThoughtSortApp: App {
    @StateObject private var navigationService = NavigationService.shared
    @StateObject private var authService = AuthenticationService.shared
    
    init() {
        FirebaseService.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                NavigationStack(path: $navigationService.navigationPath) {
                    Group {
                        switch navigationService.currentRoute {
                        case .splash:
                            SplashView()
                        case .login:
                            LoginView()
                        case .signUp:
                            SignUpView()
                        case .home:
                            HomeView()
                        case .archive:
                            ArchiveView()
                        case .taskList(let list):
                            TaskListView(list: list)
                        case .settings:
                            SettingsView()
                        }
                    }
                }
                
                LoadingOverlay()
            }
            .alert(
                navigationService.presentedAlert?.title ?? "",
                isPresented: .init(
                    get: { navigationService.presentedAlert != nil },
                    set: { if !$0 { navigationService.dismissAlert() } }
                )
            ) {
                if let primaryButton = navigationService.presentedAlert?.primaryButton {
                    Button(primaryButton.title, role: primaryButton.role) {
                        primaryButton.action()
                    }
                }
                
                if let secondaryButton = navigationService.presentedAlert?.secondaryButton {
                    Button(secondaryButton.title, role: secondaryButton.role) {
                        secondaryButton.action()
                    }
                }
            } message: {
                if let message = navigationService.presentedAlert?.message {
                    Text(message)
                }
            }
            .sheet(item: $navigationService.presentedSheet) { route in
                Group {
                    switch route {
                    case .signUp:
                        SignUpView()
                    case .settings:
                        SettingsView()
                    default:
                        EmptyView()
                    }
                }
            }
        }
    }
} 