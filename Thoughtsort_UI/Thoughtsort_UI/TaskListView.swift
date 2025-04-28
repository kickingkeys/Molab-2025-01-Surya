//
//  TaskListView.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi
//

import SwiftUI

struct TaskListView: View {
    var taskListId: String = ""
    
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTaskTitle = ""
    @State private var showingAddTask = false
    @State private var isTaskInputFocused = false

    private var taskList: TaskList? {
        taskListViewModel.activeLists.first(where: { $0.id == taskListId })
    }

    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                // Header: Back button and title
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(ThemeColors.textDark)
                    }
                    
                    Spacer()
                    
                    Text(taskList?.title ?? "Today's Tasks")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(ThemeColors.textDark)
                    
                    Spacer()
                    
                    // Placeholder spacer for alignment
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                Divider()
                    .padding(.top, 10)

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
                    
                    TextField("Add a new task...", text: $newTaskTitle, onCommit: {
                        addNewTask()
                    })
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ThemeColors.textDark)
                    .padding(.vertical, 12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)

                // Tasks list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let taskList = taskList {
                            if taskList.tasks.isEmpty {
                                Text("No tasks yet. Start by adding one!")
                                    .foregroundColor(ThemeColors.textLight)
                                    .padding(.top, 50)
                                    .frame(maxWidth: .infinity, alignment: .center)
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
                                    .onTapGesture {
                                        taskListViewModel.toggleTaskCompletion(taskListId: taskListId, taskId: task.id)
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
                .background(ThemeColors.background)

                Spacer()

                // Archive List button
                Button(action: {
                    if let id = taskList?.id {
                        taskListViewModel.archiveTaskList(id)
                        dismiss()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "archivebox")
                        Text("Archive List")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(ThemeColors.buttonLight)
                    .cornerRadius(10)
                    .foregroundColor(ThemeColors.accent)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            taskListViewModel.loadActiveLists()
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskListId: taskListId)
                .environmentObject(taskListViewModel)
        }
    }
    
    private func addNewTask() {
        if !taskListId.isEmpty && !newTaskTitle.isEmpty {
            taskListViewModel.addTask(to: taskListId, taskTitle: newTaskTitle)
            newTaskTitle = ""
        }
    }
}

// MARK: - AddTaskView

struct AddTaskView: View {
    var taskListId: String
    @Environment(\.dismiss) private var dismiss
    @State private var taskTitle = ""
    @EnvironmentObject private var taskListViewModel: TaskListViewModel

    var body: some View {
        NavigationView {
            Form {
                TextField("Task title", text: $taskTitle)
                
                Button("Add Task") {
                    if !taskTitle.isEmpty {
                        taskListViewModel.addTask(to: taskListId, taskTitle: taskTitle)
                        dismiss()
                    }
                }
                .disabled(taskTitle.isEmpty)
            }
            .navigationTitle("Add New Task")
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
