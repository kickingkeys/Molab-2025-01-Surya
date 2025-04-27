//
//  UserSessionManager.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 27/04/25.
//

import Foundation
import FirebaseAuth

class UserSessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var userEmail: String = ""
    
    func signInWithGoogle() {
        // This will be implemented with Google Sign-In
        // For now, we'll simulate login success
        self.isLoggedIn = true
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
