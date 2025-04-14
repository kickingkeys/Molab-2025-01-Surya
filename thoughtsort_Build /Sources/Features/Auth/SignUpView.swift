import SwiftUI

struct SignUpView: View {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var navigationService = NavigationService.shared
    @StateObject private var loadingService = LoadingService.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.editorialNewRegular(size: 28))
                        .lineSpacing(33.60)
                        .foregroundColor(.textPrimary)
                    
                    Text("Sign up to get started")
                        .font(.neueMontreal(size: 14))
                        .lineSpacing(21)
                        .foregroundColor(.textPrimary)
                }
                .padding(.top, 64)
                
                // Sign Up Form
                VStack(spacing: 16) {
                    // Email Field
                    TextField("Email", text: $email)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    // Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.newPassword)
                    
                    // Confirm Password Field
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(CustomTextFieldStyle())
                        .textContentType(.newPassword)
                }
                
                // Sign Up Button
                Button(action: handleSignUp) {
                    if loadingService.state.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .backgroundPrimary))
                    } else {
                        Text("Sign Up")
                            .font(.montrealMedium(size: 16))
                            .lineSpacing(19.20)
                            .foregroundColor(.backgroundPrimary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 51)
                .background(Color.accentBrand)
                .cornerRadius(100)
                .disabled(loadingService.state.isLoading || !isFormValid)
                
                // Google Sign Up
                Button(action: handleGoogleSignIn) {
                    HStack(spacing: 8) {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("Sign up with Google")
                            .font(.montrealMedium(size: 16))
                            .lineSpacing(19.20)
                            .foregroundColor(.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 51)
                    .background(Color.backgroundPrimary)
                    .cornerRadius(100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.textPrimary, lineWidth: 0.5)
                    )
                }
                .disabled(loadingService.state.isLoading)
                
                Spacer()
                
                // Back to Sign In
                Button("Already have an account? Sign In") {
                    navigationService.dismissSheet()
                }
                .font(.montrealMedium(size: 14))
                .foregroundColor(.accentBrand)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword &&
        password.count >= 6
    }
    
    private func handleSignUp() {
        guard isFormValid else {
            navigationService.showAlert(
                AlertItem(
                    title: "Error",
                    message: "Please fill in all fields correctly",
                    primaryButton: AlertItem.AlertButton(title: "OK")
                )
            )
            return
        }
        
        Task {
            do {
                loadingService.startLoading("Creating account...")
                try await authService.signUp(email: email, password: password)
                loadingService.stopLoading()
                navigationService.dismissSheet()
                navigationService.navigate(to: .home)
            } catch let error as AuthError {
                loadingService.stopLoading()
                navigationService.showAlert(
                    AlertItem(
                        title: "Error",
                        message: error.localizedDescription,
                        primaryButton: AlertItem.AlertButton(title: "OK")
                    )
                )
            } catch {
                loadingService.stopLoading()
                navigationService.showAlert(
                    AlertItem(
                        title: "Error",
                        message: "An unexpected error occurred",
                        primaryButton: AlertItem.AlertButton(title: "OK")
                    )
                )
            }
        }
    }
    
    private func handleGoogleSignIn() {
        Task {
            do {
                loadingService.startLoading("Signing up with Google...")
                try await authService.signInWithGoogle()
                loadingService.stopLoading()
                navigationService.dismissSheet()
                navigationService.navigate(to: .home)
            } catch let error as AuthError {
                loadingService.stopLoading()
                navigationService.showAlert(
                    AlertItem(
                        title: "Error",
                        message: error.localizedDescription,
                        primaryButton: AlertItem.AlertButton(title: "OK")
                    )
                )
            } catch {
                loadingService.stopLoading()
                navigationService.showAlert(
                    AlertItem(
                        title: "Error",
                        message: "An unexpected error occurred",
                        primaryButton: AlertItem.AlertButton(title: "OK")
                    )
                )
            }
        }
    }
}

#Preview {
    SignUpView()
} 