//
//  AppDelegate.swift
//  Assignment_06legocam
//
//  Created by Surya Narreddi on 13/03/25.
//

import UIKit
import Photos


class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request camera and photo library permissions when app starts
        requestCameraPermission()
        requestPhotoLibraryPermission()
        return true
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                print("Camera permission granted")
            } else {
                print("Camera permission denied")
            }
        }
    }
    
    private func requestPhotoLibraryPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                print("Photo library permission granted")
            default:
                print("Photo library permission not granted")
            }
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
