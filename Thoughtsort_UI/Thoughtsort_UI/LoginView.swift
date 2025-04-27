import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @EnvironmentObject private var sessionManager: UserSessionManager
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo and header
                VStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(ThemeColors.accent)
                            .frame(width: 64, height: 64)
                    }
                    
                    Text("Take control of your day")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                    
                    Text("Create an account or log in")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textDark)
                }
                .padding(.bottom, 30)
                
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeColors.textDark)
                    
                    TextField("yourname@email.com", text: $email)
                        .padding()
                        .background(ThemeColors.inputBackground)
                        .cornerRadius(8)
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeColors.textDark)
                    
                    SecureField("Enter password", text: $password)
                        .padding()
                        .background(ThemeColors.inputBackground)
                        .cornerRadius(8)
                    
                    HStack {
                        Spacer()
                        Button("Forgot your password?") {
                            if !email.isEmpty {
                                sessionManager.resetPassword(email: email) { result in
                                    switch result {
                                    case .success:
                                        alertMessage = "Password reset email sent to \(email)"
                                    case .failure(let error):
                                        alertMessage = "Error: \(error.localizedDescription)"
                                    }
                                    showAlert = true
                                }
                            } else {
                                alertMessage = "Please enter your email address first"
                                showAlert = true
                            }
                        }
                        .foregroundColor(ThemeColors.accent)
                        .font(.system(size: 14))
                    }
                }
                
                // Login button
                Button {
                    sessionManager.signInWithEmail(email: email, password: password) { result in
                        switch result {
                        case .success:
                            // Navigation is handled by ContentView based on sessionManager.isLoggedIn
                            print("Login successful")
                        case .failure(let error):
                            alertMessage = "Login failed: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                } label: {
                    Text("Log in")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ThemeColors.accent)
                        .cornerRadius(25)
                }
                .padding(.top, 10)
                
                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("or")
                        .foregroundColor(ThemeColors.textDark)
                        .padding(.horizontal, 10)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.vertical, 15)
                
                // Google button
                Button {
                    sessionManager.signInWithGoogle()
                } label: {
                    HStack {
                        Image(systemName: "globe") // Using system image as placeholder
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Continue with Google")
                            .font(.system(size: 16))
                            .foregroundColor(ThemeColors.textDark)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Spacer()
                
                // Sign up link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(ThemeColors.textDark)
                    
                    Button("Sign Up") {
                        if !email.isEmpty && !password.isEmpty {
                            sessionManager.createAccount(email: email, password: password) { result in
                                switch result {
                                case .success:
                                    // Navigation is handled by ContentView
                                    print("Account created successfully")
                                case .failure(let error):
                                    alertMessage = "Account creation failed: \(error.localizedDescription)"
                                    showAlert = true
                                }
                            }
                        } else {
                            alertMessage = "Please enter email and password"
                            showAlert = true
                        }
                    }
                    .foregroundColor(ThemeColors.accent)
                    .fontWeight(.bold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            
            if sessionManager.isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.accent))
                        .scaleEffect(1.5)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                        )
                }
            }
        }
    }
}
