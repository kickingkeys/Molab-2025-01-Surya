import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    @EnvironmentObject var sessionManager: UserSessionManager
    @EnvironmentObject var taskListViewModel: TaskListViewModel

    var body: some View {
        ZStack {
            if isShowingSplash {
                LaunchScreen()
            } else if sessionManager.isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if sessionManager.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            // debugPrintFonts() // 🛑 Commented out to reduce console log noise
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isShowingSplash = false
                }
            }
        }
    }
    
    // Debug helper
    func debugPrintFonts() {
        for family in UIFont.familyNames.sorted() {
            print("Font family: \(family)")
            for font in UIFont.fontNames(forFamilyName: family).sorted() {
                print("- \(font)")
            }
        }
    }
}
