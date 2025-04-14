import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

enum AuthError: LocalizedError {
    case notAuthenticated
    case signInFailed(String)
    case signOutFailed(String)
    case googleSignInFailed(String)
    case userCancelled
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action"
        case .signInFailed(let message):
            return "Sign in failed: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .googleSignInFailed(let message):
            return "Google sign in failed: \(message)"
        case .userCancelled:
            return "Sign in was cancelled"
        case .networkError:
            return "Network error occurred. Please check your connection"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

@MainActor
class AuthenticationService: ObservableObject {
    static let shared = AuthenticationService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: AuthError?
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
        }
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
            isAuthenticated = true
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    func signUp(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            currentUser = result.user
            isAuthenticated = true
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    func signOut() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    func resetPassword(email: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    func signInWithGoogle() async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.googleSignInFailed("Client ID not found")
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.googleSignInFailed("No root view controller found")
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.googleSignInFailed("No ID token found")
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            currentUser = authResult.user
            isAuthenticated = true
        } catch let error as NSError {
            if error.code == GIDSignInError.canceled.rawValue {
                throw AuthError.userCancelled
            }
            throw mapFirebaseError(error)
        }
    }
    
    private func mapFirebaseError(_ error: NSError) -> AuthError {
        switch error.code {
        case AuthErrorCode.networkError.rawValue:
            return .networkError
        case AuthErrorCode.userCancelled.rawValue:
            return .userCancelled
        case AuthErrorCode.invalidEmail.rawValue:
            return .signInFailed("Invalid email address")
        case AuthErrorCode.wrongPassword.rawValue:
            return .signInFailed("Incorrect password")
        case AuthErrorCode.userNotFound.rawValue:
            return .signInFailed("No account found with this email")
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .signInFailed("Email already in use")
        case AuthErrorCode.weakPassword.rawValue:
            return .signInFailed("Password is too weak")
        default:
            return .unknown
        }
    }
} 