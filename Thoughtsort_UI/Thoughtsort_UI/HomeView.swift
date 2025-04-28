//
//  HomeView.swift
//  Thoughtsort_UI
//

import SwiftUI

struct HomeView: View {
    @State private var taskText = ""
    @State private var isShowingTaskList = false
    @State private var isShowingSettings = false

    private var currentDateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()

                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .top, spacing: 8) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Create your To-Do List")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(ThemeColors.textDark)

                            Text(currentDateFormatted)
                                .font(.system(size: 14))
                                .foregroundColor(ThemeColors.textDark)
                        }

                        Spacer()

                        Button(action: {
                            isShowingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(ThemeColors.textDark)
                                .padding(.top, 4) // Adjusted padding to align with text top
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Divider
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray.opacity(0.4))
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundColor(.gray.opacity(0.4))
                        )
                        .padding(.top, 10)
                        .padding(.horizontal, 20)

                    // Input area
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $taskText)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .frame(height: 140)
                            .background(ThemeColors.inputBackground)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.clear, lineWidth: 0)
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .font(.body)
                            .foregroundColor(.primary)

                        if taskText.isEmpty {
                            Text("Feeling overwhelmed? Type everything you need to do here, and I'll help organise your thoughts...")
                                .foregroundColor(Color(.systemGray))
                                .font(.body)
                                .padding(.leading, 32)
                                .padding(.top, 32)
                        }
                    }

                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "mic.fill")
                                    .foregroundColor(ThemeColors.textDark)
                                Text("Record")
                                    .foregroundColor(ThemeColors.textDark)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(ThemeColors.background)
                            .cornerRadius(25)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(ThemeColors.textDark.opacity(0.3), lineWidth: 1)
                            )
                        }

                        Button(action: {
                            isShowingTaskList = true
                        }) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(.white)
                                Text("Organize")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(ThemeColors.accent)
                            .cornerRadius(25)
                        }
                        .navigationDestination(isPresented: $isShowingTaskList) {
                            TaskListView()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)

                    // Your Lists section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Lists for Today")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(ThemeColors.textDark)
                            .padding(.top, 30)

                        // List item
                        Button(action: {
                            isShowingTaskList = true
                        }) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Grocery Day")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(ThemeColors.textDark)

                                HStack(spacing: 4) {
                                    Text("6 Items")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(.systemGray))

                                    Circle()
                                        .fill(Color(.systemGray))
                                        .frame(width: 4, height: 4)

                                    Text("4 Completed")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(.systemGray))

                                    Circle()
                                        .fill(Color(.systemGray))
                                        .frame(width: 4, height: 4)

                                    Text("Last edited 12:35 PM")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color(.systemGray))
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(ThemeColors.inputBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // Tab bar
                    HStack(spacing: 0) {
                        HStack {
                            Spacer()
                            VStack(spacing: 5) {
                                Image(systemName: "house.fill")
                                    .foregroundColor(ThemeColors.accent)
                                Text("Home")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.accent)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ThemeColors.buttonLight)

                        HStack {
                            Spacer()
                            VStack(spacing: 5) {
                                Image(systemName: "archivebox")
                                    .foregroundColor(ThemeColors.textDark)
                                Text("Archive")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textDark)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ThemeColors.inputBackground.opacity(0.5))
                    }
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                }
            }
            .navigationDestination(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
