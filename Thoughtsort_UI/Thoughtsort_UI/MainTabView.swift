//
//  MainTabView.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 28/04/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userSessionManager: UserSessionManager
    @EnvironmentObject var taskListViewModel: TaskListViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                }
                .tag(0)

            ArchiveView()
                .tabItem {
                    VStack {
                        Image(systemName: "archivebox")
                        Text("Archive")
                    }
                }
                .tag(1)
        }
        .accentColor(ThemeColors.accent) // Sets active tab highlight color
    }
}
