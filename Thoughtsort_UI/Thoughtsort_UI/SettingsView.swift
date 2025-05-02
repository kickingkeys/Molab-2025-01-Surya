import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var userSessionManager: UserSessionManager

    @State private var claudeKey: String = KeychainManager.getAPIKey() ?? ""
    @State private var isKeyVisible: Bool = false

    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                header

                Text("Signed in as")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 20)

                if let user = Auth.auth().currentUser {
                    Text(user.email ?? "No email found")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                        .padding(.horizontal, 20)
                }

                claudeAPIKeyInput

                Spacer()

                logoutButton
            }
            .padding(.top, 40)
        }
    }

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(ThemeColors.textDark)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private var claudeAPIKeyInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Claude API Key")
                .font(.system(size: 14))
                .foregroundColor(Color(.systemGray))

            HStack {
                Group {
                    if isKeyVisible {
                        TextField("Enter Claude API Key", text: $claudeKey)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Enter Claude API Key", text: $claudeKey)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                }
                .padding()
                .background(ThemeColors.inputBackground)
                .cornerRadius(12)
                .foregroundColor(ThemeColors.textDark)

                Button(action: {
                    isKeyVisible.toggle()
                }) {
                    Image(systemName: isKeyVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(ThemeColors.textDark)
                        .padding(.trailing, 4)
                }
            }
            .onChange(of: claudeKey) { newValue in
                print("🔐 Saving Claude API key with length: \(newValue.count)")
                KeychainManager.saveAPIKey(newValue)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var logoutButton: some View {
        Button(action: {
            userSessionManager.signOut()
        }) {
            HStack {
                Spacer()
                Text("Sign Out")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                Spacer()
            }
            .padding()
            .background(Color.red)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}
