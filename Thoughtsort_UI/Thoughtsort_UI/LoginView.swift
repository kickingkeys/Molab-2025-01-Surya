import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    
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
                            // Forgot password action
                        }
                        .foregroundColor(ThemeColors.accent)
                        .font(.system(size: 14))
                    }
                }
                
                // Login button
                Button {
                    // Navigate to TodoListView
                    isLoggedIn = true
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
                    isLoggedIn = true
                } label: {
                    HStack {
                        Image("google_icon") // Use system image as fallback
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
                        // Sign up action
                    }
                    .foregroundColor(ThemeColors.accent)
                    .fontWeight(.bold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
        }
        .navigationDestination(isPresented: $isLoggedIn) {
            TodoListView()
        }
    }
}

// Placeholder TodoListView struct remains the same
