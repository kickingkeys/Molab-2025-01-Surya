import SwiftUI

struct TaskListView: View {
    var taskListId: String = ""
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newTaskTitle = ""
    @State private var showingAddTask = false
    
    private var taskList: TaskList? {
        taskListViewModel.activeLists.first(where: { $0.id == taskListId })
    }
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header with back button
                HStack(alignment: .center) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Back")
                                .foregroundColor(.blue)
                        }
                    }
                    Spacer()
                }
                .padding(.top, 5)
                .padding(.leading, 20)
                
                // Title and timestamp
                VStack(alignment: .leading, spacing: 5) {
                    Text(taskList?.title ?? "Today's Tasks")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                    
                    if let createdAt = taskList?.createdAt {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMMM d, yyyy, h:mm a"
                        Text("Created on \(dateFormatter.string(from: createdAt))")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textDark)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.top, 10)
                
                // Task list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let taskList = taskList {
                            ForEach(taskList.tasks) { task in
                                HStack(spacing: 8) {
                                    // Task checkbox
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
                                    
                                    // Task title
                                    Text(task.title)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(ThemeColors.textDark)
                                        .strikethrough(task.isCompleted)
                                }
                                .onTapGesture {
                                    taskListViewModel.toggleTaskCompletion(taskListId: taskListId, taskId: task.id)
                                }
                            }
                        } else {
                            Text("Loading tasks...")
                                .foregroundColor(ThemeColors.textLight)
                                .padding()
                        }
                        
                        // Add task button
                        Button(action: {
                            showingAddTask = true
                        }) {
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
                                
                                Text("Add more items")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(ThemeColors.textDark)
                            }
                            .padding(.top, 5)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                
                Spacer()
                
                // Footer text
                Text("Every list is archived at the end of the day, and you can find them in your archived tab.")
                    .font(.system(size: 14))
                    .italic()
                    .foregroundColor(ThemeColors.textDark.opacity(0.85))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                
                // Archive button (left-aligned)
                HStack {
                    Button(action: {
                        if let id = taskList?.id {
                            taskListViewModel.archiveTaskList(id)
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "archivebox")
                                .foregroundColor(ThemeColors.textDark)
                            
                            Text("Archive this list")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.textDark)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                    }
                    .background(ThemeColors.background)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(ThemeColors.textDark, lineWidth: 0.5)
                    )
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(taskListId: taskListId)
        }
    }
}

// AddTaskView for adding new tasks
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
                    // Add task logic would go here
                    // This requires updating our FirestoreManager to support adding individual tasks
                    dismiss()
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
