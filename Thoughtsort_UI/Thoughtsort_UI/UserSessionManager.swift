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
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            isLoading = false
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] signInResult, error in
            guard let self = self else { return }
            guard let result = signInResult, error == nil else {
                self.isLoading = false
                return
            }
            
            guard let idToken = result.user.idToken?.tokenString else {
                self.isLoading = false
                return
            }
            let accessToken = result.user.accessToken.tokenString
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                self.isLoading = false
                if let user = authResult?.user {
                    self.isLoggedIn = true
                    self.userEmail = user.email ?? ""
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
