//
//  Thoughtsort_UIApp.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 21/04/25.
//

import SwiftUI
import FirebaseCore

@main
struct Thoughtsort_UIApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
