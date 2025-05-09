import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase
import SwiftUI

class UserSessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userEmail: String = ""
    @Published var isLoading: Bool = true
    
    init() {
        // Check if user is already logged in
        checkAuthState()
    }
    
    private func checkAuthState() {
        isLoading = true
        if let user = Auth.auth().currentUser {
            self.isLoggedIn = true
            self.userEmail = user.email ?? ""
        } else {
            self.isLoggedIn = false
            self.userEmail = ""
        }
        isLoading = false
    }
    
    func signInWithGoogle() {
        isLoading = true
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            isLoading = false
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
              let rootVC = windowScene.windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController else {
                isLoading = false
                return
        }
        
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                print("Google Sign-In failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {
                print("Google Sign-In failed: no user object")
                return
            }
            
            // Proceed with authentication (exchange tokens with Firebase)
            guard let idToken = user.idToken?.tokenString else {
                return
            }
            
            let accessToken = user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Sign-In failed: \(error.localizedDescription)")
                    return
                }
                
                if let user = authResult?.user {
                    self.isLoggedIn = true
                    self.userEmail = user.email ?? ""
                    print("User signed in successfully: \(user.email ?? "No Email")")
                }
            }
        }
    }

    
    func signInWithEmail(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = authResult?.user {
                self.isLoggedIn = true
                self.userEmail = user.email ?? ""
                completion(.success(()))
            }
        }
    }
    
    func createAccount(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let user = authResult?.user {
                self.isLoggedIn = true
                self.userEmail = user.email ?? ""
                completion(.success(()))
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isLoggedIn = false
            self.userEmail = ""
        } catch {
            print("Error signing out: \(error)")
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
