//
//  HomeView 2.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 28/04/25.
//


import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var userSessionManager: UserSessionManager
    @EnvironmentObject var taskListViewModel: TaskListViewModel

    @State private var taskText = ""
    @State private var showSettings = false
    @State private var showDeleteConfirmation = false
    @State private var listToDelete: TaskList?

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Create your To-Do List")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(ThemeColors.textDark)

                            HStack(spacing: 4) {
                                Text(Date(), style: .date)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textDark)
                                Text("•")
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textDark)
                                Text(Date(), style: .time)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textDark)
                            }
                        }

                        Spacer()

                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(ThemeColors.textDark)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Dotted Divider
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundColor(ThemeColors.textDark.opacity(0.3))
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                    // Input Area
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $taskText)
                            .scrollContentBackground(.hidden)
                            .padding(12)
                            .frame(height: 140)
                            .background(ThemeColors.inputBackground)
                            .cornerRadius(16)
                            .font(.body)
                            .foregroundColor(ThemeColors.textDark)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)

                        if taskText.isEmpty {
                            Text("Feeling overwhelmed? Type everything you need to do here, and I'll help organise your thoughts...")
                                .foregroundColor(Color(.systemGray))
                                .font(.body)
                                .padding(.leading, 32)
                                .padding(.top, 32)
                                .allowsHitTesting(false)
                        }
                    }

                    // Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            // Record action (future speech-to-text)
                        }) {
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
                            if !taskText.isEmpty {
                                let title = formattedNewTaskListTitle()
                                taskListViewModel.createTaskList(title: title)
                                taskText = ""
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    taskListViewModel.loadActiveLists()
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(.white)
                                Text("Organize")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, minHeight: 51, maxHeight: 51)
                            .background(Color(red: 0.93, green: 0.41, blue: 0.17))
                            .cornerRadius(100)
                            .opacity(taskText.isEmpty ? 0.5 : 1)
                        }
                        .disabled(taskText.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)

                    // Lists Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Lists for Today")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(ThemeColors.textDark)
                            .padding(.top, 30)
                            .padding(.horizontal, 20)

                        if taskListViewModel.activeLists.isEmpty {
                            Text("No task lists found. Start by creating one!")
                                .font(.system(size: 16))
                                .foregroundColor(ThemeColors.textLight)
                                .padding(.top, 10)
                                .padding(.horizontal, 20)
                        } else {
                            List {
                                ForEach(taskListViewModel.activeLists.sorted { $0.createdAt > $1.createdAt }) { list in
                                    NavigationLink(destination: TaskListView(taskListId: list.id)
                                        .environmentObject(taskListViewModel)) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(formattedTaskListTitle(list: list))
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(ThemeColors.textDark)

                                            HStack(spacing: 4) {
                                                Text("\(list.tasks.count) Items")
                                                Text("•")
                                                Text("\(list.tasks.filter { $0.isCompleted }.count) Completed")
                                                Text("•")
                                                Text("Last edited \(list.createdAt, style: .time)")
                                            }
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(ThemeColors.textLight)
                                        }
                                        .padding(8)
                                    }
                                    .listRowBackground(ThemeColors.background) // ✅ Force each row background
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            listToDelete = list
                                            showDeleteConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .listStyle(PlainListStyle())
                            .scrollContentBackground(.hidden) // ✅ Hides dark List background
                            .background(ThemeColors.background) // ✅ Overall list background
                        }
                    }
                }
            }
            .confirmationDialog("Are you sure you want to delete this list?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let list = listToDelete {
                        taskListViewModel.deleteTaskList(listId: list.id)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            taskListViewModel.loadActiveLists()
                        }
                    }
                    listToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    listToDelete = nil
                }
            }
        }
        .onAppear {
            taskListViewModel.loadActiveLists()
        }
    }
    
    // 📅 Format Title for a New Task List
    private func formattedNewTaskListTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "Tasks • \(formatter.string(from: Date()))"
    }
    
    // 📅 Format Display Title for Each List
    private func formattedTaskListTitle(list: TaskList) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "Tasks • \(formatter.string(from: list.createdAt))"
    }
}
