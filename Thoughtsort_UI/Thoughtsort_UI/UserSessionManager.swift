import Foundation
import FirebaseAuth
import GoogleSignIn
import Firebase  // Add this import
import SwiftUI

class UserSessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userEmail: String = ""
    
    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { [weak self] user, error in
            guard let self = self,
                  let user = user,
                  error == nil else { return }
                  
            guard let authentication = user.authentication else { return }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: authentication.idToken!,
                accessToken: authentication.accessToken
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let user = authResult?.user {
                    self.isLoggedIn = true
                    self.userEmail = user.email ?? ""
                }
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
}
