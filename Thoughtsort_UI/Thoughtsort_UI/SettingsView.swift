//
//  SettingsView.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 27/04/25.
//

//
//  SettingsView.swift
//  Thoughtsort_UI
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionManager: UserSessionManager

    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text("Settings")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(ThemeColors.textDark)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Signed in as")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textDark.opacity(0.7))

                    Text(sessionManager.userEmail)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                }
                .padding()
                .background(ThemeColors.inputBackground)
                .cornerRadius(12)
                .padding(.horizontal, 20)

                Spacer()

                Button(action: handleSignOut) {
                    Text("Sign Out")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(25)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(false)
    }

    private func handleSignOut() {
        do {
            try Auth.auth().signOut()
            sessionManager.isLoggedIn = false
            sessionManager.userEmail = ""
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSessionManager())
    }
}
