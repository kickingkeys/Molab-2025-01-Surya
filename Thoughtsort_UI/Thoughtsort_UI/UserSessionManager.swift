func signInWithGoogle() {
    guard let clientID = FirebaseApp.app()?.options.clientID else { return }
    let config = GIDConfiguration(clientID: clientID)
    
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        return
    }
    
    GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
        guard let result = signInResult, error == nil else { return }
        
        guard let idToken = result.user.idToken?.tokenString else { return }
        let accessToken = result.user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let user = authResult?.user {
                self.isLoggedIn = true
                self.userEmail = user.email ?? ""
            }
        }
    }
}
