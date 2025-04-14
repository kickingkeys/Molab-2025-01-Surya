import SwiftUI
import Firebase

struct LoginView: View {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var navigationService = NavigationService.shared
    @StateObject private var loadingService = LoadingService.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingForgotPassword = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.editorialNewRegular(size: 28))
                            .lineSpacing(33.60)
                            .foregroundColor(.textPrimary)
                        
                        Text("Sign in to continue")
                            .font(.neueMontreal(size: 14))
                            .lineSpacing(21)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.top, 64)
                    
                    // Sign In Form
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
                            .textContentType(.password)
                    }
                    
                    // Forgot Password
                    Button("Forgot Password?") {
                        handleForgotPassword()
                    }
                    .font(.montrealMedium(size: 14))
                    .foregroundColor(.accentBrand)
                    
                    // Sign In Button
                    Button(action: handleSignIn) {
                        if loadingService.state.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .backgroundPrimary))
                        } else {
                            Text("Sign In")
                                .font(.montrealMedium(size: 16))
                                .lineSpacing(19.20)
                                .foregroundColor(.backgroundPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 51)
                    .background(Color.accentBrand)
                    .cornerRadius(100)
                    .disabled(loadingService.state.isLoading)
                    
                    // Google Sign In
                    Button(action: handleGoogleSignIn) {
                        HStack(spacing: 8) {
                            Image("google_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                            
                            Text("Sign in with Google")
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
                    
                    // Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.neueMontreal(size: 14))
                            .foregroundColor(.textPrimary)
                        
                        Button("Sign Up") {
                            navigationService.presentSheet(.signUp)
                        }
                        .font(.montrealMedium(size: 14))
                        .foregroundColor(.accentBrand)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationDestination(isPresented: $showingSignUp) {
            SignUpView()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { showingError = false }
        } message: {
            Text(errorMessage)
        }
        .alert("Reset Password", isPresented: $showingForgotPassword) {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button("Cancel", role: .cancel) { }
            Button("Send Reset Link") {
                handleForgotPassword()
            }
        } message: {
            Text("Enter your email address and we'll send you a link to reset your password.")
        }
    }
    
    private func handleSignIn() {
        Task {
            do {
                loadingService.startLoading("Signing in...")
                try await authService.signIn(email: email, password: password)
                loadingService.stopLoading()
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
                loadingService.startLoading("Signing in with Google...")
                try await authService.signInWithGoogle()
                loadingService.stopLoading()
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
    
    private func handleForgotPassword() {
        navigationService.showAlert(
            AlertItem(
                title: "Reset Password",
                message: "Enter your email address and we'll send you a link to reset your password.",
                primaryButton: AlertItem.AlertButton(title: "Send Reset Link") {
                    Task {
                        do {
                            loadingService.startLoading("Sending reset link...")
                            try await authService.resetPassword(email: email)
                            loadingService.stopLoading()
                            navigationService.showAlert(
                                AlertItem(
                                    title: "Success",
                                    message: "Password reset email sent. Please check your inbox.",
                                    primaryButton: AlertItem.AlertButton(title: "OK")
                                )
                            )
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
                },
                secondaryButton: AlertItem.AlertButton(title: "Cancel", role: .cancel)
            )
        )
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.neueMontreal(size: 14))
            .lineSpacing(21)
            .foregroundColor(.textPrimary)
            .padding(12)
            .background(Color.inputBackground)
            .cornerRadius(12)
    }
}

#Preview {
    LoginView()
} 
} 