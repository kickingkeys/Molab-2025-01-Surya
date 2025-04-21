import SwiftUI

struct ContentView: View {
    @State private var isShowingSplash = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                if isShowingSplash {
                    LaunchScreen()
                } else {
                    LoginView()
                }
            }
            .onAppear {
                // Show splash screen for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isShowingSplash = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
