import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    @EnvironmentObject var sessionManager: UserSessionManager
    @EnvironmentObject var taskListViewModel: TaskListViewModel

    var body: some View {
        ZStack {
            if isShowingSplash {
                splashOverlay
                    .transition(.opacity)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Fade out after 1.5s
                withAnimation(.easeOut(duration: 0.5)) {
                    isShowingSplash = false
                }
            }
        }
    }

    private var splashOverlay: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 12) {
                Image("AppIcon")
                    .resizable()
                    .frame(width: 100, height: 100)
                Text("thoughtsort")
                    .font(.custom("PPEditorialNew-Regular", size: 28))
                    .foregroundColor(Color(red: 0.32, green: 0.32, blue: 0.32))
            }
        }
    }
}
