import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userSessionManager: UserSessionManager

    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Settings")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(ThemeColors.textDark)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                // Signed-in user email
                VStack(alignment: .leading, spacing: 8) {
                    Text("Signed in as")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.systemGray))

                    Text(userSessionManager.userEmail)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ThemeColors.inputBackground)
                .cornerRadius(12)
                .padding(.horizontal, 20)

                Spacer()

                // Sign Out button
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        userSessionManager.isLoggedIn = false
                        userSessionManager.userEmail = ""
                        dismiss()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ThemeColors.accent)
                        .cornerRadius(30)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(false)
        .tint(ThemeColors.textDark)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(UserSessionManager())
    }
}
