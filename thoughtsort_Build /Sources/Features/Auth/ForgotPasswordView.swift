import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthenticationService
    @State private var email = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Reset Password")
                    .font(.editorialNewRegular(size: 28))
                    .foregroundColor(.textPrimary)
                
                Text("Enter your email address and we'll send you instructions to reset your password.")
                    .font(.neueMontreal(size: 14))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.montrealMedium(size: 14))
                        .foregroundColor(.textPrimary)
                    
                    TextField("yourname@email.com", text: $email)
                        .font(.neueMontreal(size: 14))
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(12)
                        .background(Color(red: 0.86, green: 0.87, blue: 0.84))
                        .cornerRadius(12)
                }
                
                Button(action: handleResetPassword) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Reset Link")
                            .font(.montrealMedium(size: 16))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(Color.accentBrand)
                .foregroundColor(.white)
                .cornerRadius(100)
                .disabled(isLoading)
                
                Spacer()
            }
            .padding(20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.textPrimary)
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { showError = false }
        } message: {
            Text(errorMessage)
        }
        .alert("Success", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Password reset instructions have been sent to your email.")
        }
    }
    
    private func handleResetPassword() {
        isLoading = true
        Task {
            do {
                try await authService.resetPassword(email: email)
                showSuccess = true
            } catch {
                showError = true
                errorMessage = FirebaseError(error: error).localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    ForgotPasswordView()
        .environmentObject(AuthenticationService())
} 