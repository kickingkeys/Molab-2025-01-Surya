//
//  TaskListView.swift
//  Thoughtsort_UI
//

import SwiftUI

struct TaskListView: View {
    var taskListId: String = ""
    
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTaskTitle = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var isGenerating = false

    private var taskList: TaskList? {
        taskListViewModel.activeLists.first(where: { $0.id == taskListId })
    }

    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(ThemeColors.textDark)
                    }
                    .padding(.bottom, 5)

                    Text("Tasks")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                    
                    if let createdAt = taskList?.createdAt {
                        Text("Edited on \(formattedDateTime(date: createdAt))")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textDark)
                    }

                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundColor(ThemeColors.textDark.opacity(0.3))
                        )
                        .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Add new task input
                HStack(spacing: 8) {
                    ZStack {
                        Rectangle()
                            .fill(ThemeColors.buttonLight)
                            .frame(width: 16, height: 16)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(ThemeColors.accent, lineWidth: 0.5)
                            )
                        
                        Image(systemName: "plus")
                            .font(.system(size: 10))
                            .foregroundColor(ThemeColors.accent)
                    }
                    
                    TextField("Add a new task...", text: $newTaskTitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                        .padding(.vertical, 12)
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            addNewTask()
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)

                // Tasks List
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let taskList = taskList {
                            if taskList.tasks.isEmpty {
                                if isGenerating {
                                    VStack(spacing: 12) {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.textLight))
                                        Text("Generating tasks…")
                                            .foregroundColor(ThemeColors.textLight)
                                    }
                                    .padding(.top, 50)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    Text("No tasks yet. Start by adding one!")
                                        .foregroundColor(ThemeColors.textLight)
                                        .padding(.top, 50)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                }
                            } else {
                                ForEach(taskList.tasks) { task in
                                    HStack(spacing: 8) {
                                        if task.isCompleted {
                                            ZStack {
                                                Circle()
                                                    .strokeBorder(ThemeColors.accent, lineWidth: 0.5)
                                                    .frame(width: 16, height: 16)
                                                
                                                Circle()
                                                    .fill(ThemeColors.accent)
                                                    .frame(width: 10, height: 10)
                                            }
                                        } else {
                                            Circle()
                                                .strokeBorder(ThemeColors.accent, lineWidth: 0.5)
                                                .frame(width: 16, height: 16)
                                        }
                                        
                                        Text(task.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(ThemeColors.textDark)
                                            .strikethrough(task.isCompleted)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        taskListViewModel.toggleTaskCompletion(taskListId: taskListId, taskId: task.id)
                                    }
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            taskListViewModel.deleteTask(taskListId: taskListId, taskId: task.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        } else {
                            Text("Loading tasks...")
                                .foregroundColor(ThemeColors.textLight)
                                .padding()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }

                Spacer()

                // Archive Info and Button
                VStack(alignment: .leading, spacing: 12) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 1)
                        .overlay(
                            Rectangle()
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .foregroundColor(ThemeColors.textDark.opacity(0.3))
                        )

                    Text("Every list is archived at the end of the day, and you can find them in your archived tab.")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textLight)
                        .padding(.top, 10)
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            if let id = taskList?.id {
                                taskListViewModel.archiveTaskList(id)
                                dismiss()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "archivebox")
                                Text("Archive this list")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(ThemeColors.textDark.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(ThemeColors.textDark)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            taskListViewModel.loadActiveLists()

            // Detect Claude-generated empty list
            if let list = taskListViewModel.activeLists.first(where: { $0.id == taskListId }) {
                isGenerating = list.tasks.isEmpty
            }
        }
    }
    
    private func addNewTask() {
        if !taskListId.isEmpty && !newTaskTitle.isEmpty {
            taskListViewModel.addTask(to: taskListId, taskTitle: newTaskTitle)
            newTaskTitle = ""
            isTextFieldFocused = false
        }
    }
    
    private func formattedDateTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy, h:mm a"
        return formatter.string(from: date)
    }
}
