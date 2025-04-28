//
//  AppDelegate.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 27/04/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAppCheck  // ✅ Add this for App Check
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // ✅ Setup App Check Debug Provider
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        // ✅ Configure Firebase AFTER setting AppCheck Provider
        FirebaseApp.configure()

        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
