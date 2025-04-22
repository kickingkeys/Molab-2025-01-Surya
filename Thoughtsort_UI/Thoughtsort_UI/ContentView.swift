// ContentView.swift
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

#Preview {
    ContentView()
}
