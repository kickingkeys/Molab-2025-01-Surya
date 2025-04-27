import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    @EnvironmentObject var sessionManager: UserSessionManager
    @EnvironmentObject var taskListViewModel: TaskListViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isShowingSplash {
                    LaunchScreen()
                } else if sessionManager.isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if sessionManager.isLoggedIn {
                    HomeView()
                        .onAppear {
                            taskListViewModel.loadActiveLists()
                        }
                } else {
                    LoginView()
                }
            }
            .onAppear {
                debugPrintFonts()
                // Show splash screen for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isShowingSplash = false
                    }
                }
            }
        }
    }
    
    // debugging fonts
    
    func debugPrintFonts() {
        for family in UIFont.familyNames.sorted() {
            print("Font family: \(family)")
            for font in UIFont.fontNames(forFamilyName: family).sorted() {
                print("- \(font)")
            }
        }
    }
}
