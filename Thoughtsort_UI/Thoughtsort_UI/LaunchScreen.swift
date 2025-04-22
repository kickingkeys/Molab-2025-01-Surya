//
//  LaunchScreen.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 21/04/25.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 12) {
                // App Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ThemeColors.accent)
                        .frame(width: 64, height: 64)
                        .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
                }
                
                // App Name
                Text("thoughtsort")
                    .font(ThemeTypography.titleLarge)
                    .foregroundColor(ThemeColors.textDark)
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
