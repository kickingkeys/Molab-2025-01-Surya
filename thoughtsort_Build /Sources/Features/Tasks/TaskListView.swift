import SwiftUI

struct TaskListView: View {
    let list: TaskList
    @EnvironmentObject private var taskService: TaskService
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddTask = false
    @State private var newTaskText = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showingConfetti = false
    @State private var lastCompletedTaskId: String?
    
    private var tasks: [Task] {
        taskService.currentTasks[list.id] ?? []
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(list.title)
                        .font(.editorialNewRegular(size: 28))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(33.60)
                    
                    Text("Last edited \(list.lastEditedAt.formatted(date: .long, time: .shortened))")
                        .font(.neueMontreal(size: 14))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(21)
                }
                .padding(.top, 64)
                
                // Task List
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(tasks) { task in
                            TaskRow(task: task) { task in
                                Task {
                                    do {
                                        try await taskService.toggleTaskCompletion(task: task)
                                        if task.isCompleted {
                                            lastCompletedTaskId = task.id
                                            FeedbackService.shared.triggerTaskCompletionHaptic()
                                            showingConfetti = true
                                        }
                                    } catch {
                                        showingError = true
                                        errorMessage = error.localizedDescription
                                    }
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                        
                        // Add more items button
                        Button(action: { 
                            FeedbackService.shared.triggerSelectionHaptic()
                            showingAddTask = true 
                        }) {
                            HStack(spacing: 8) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: 16, height: 16)
                                        .background(Color(red: 0.94, green: 0.86, blue: 0.80))
                                        .cornerRadius(4)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 4)
                                                .stroke(Color.accentBrand, lineWidth: 0.5)
                                        )
                                }
                                
                                Text("Add more items")
                                    .font(.montrealMedium(size: 16))
                                    .foregroundColor(.textPrimary)
                                    .lineSpacing(24)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Footer note
                Text("Every list is archived at the end of the day, and you can find them in your archived tab.")
                    .font(.neueMontreal(size: 14))
                    .italic()
                    .foregroundColor(.textPrimary.opacity(0.85))
                    .lineSpacing(21)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { 
                        FeedbackService.shared.triggerSelectionHaptic()
                        dismiss() 
                    }) {
                        HStack(spacing: 8) {
                            PhosphorIconView(.arrowLeft)
                            Text("Go back")
                                .font(.montrealMedium(size: 16))
                                .lineSpacing(19.20)
                        }
                        .foregroundColor(.accentBrand)
                        .padding(.horizontal, 16)
                        .frame(height: 51)
                        .background(Color.inputBackground)
                        .cornerRadius(100)
                    }
                    
                    Button(action: {
                        FeedbackService.shared.triggerSelectionHaptic()
                        Task {
                            do {
                                try await taskService.archiveList(list)
                                dismiss()
                            } catch {
                                showingError = true
                                errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            PhosphorIconView(.archiveBox)
                            Text("Archive this list")
                                .font(.montrealMedium(size: 16))
                                .lineSpacing(19.20)
                        }
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .frame(height: 51)
                        .background(Color.inputBackground)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.textPrimary, lineWidth: 0.5)
                        )
                    }
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 20)
            
            // Confetti overlay
            if showingConfetti {
                ConfettiView()
                    .frame(height: 200)
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + FeedbackService.Duration.confetti) {
                            showingConfetti = false
                        }
                    }
            }
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $showingError) {
            Button("OK") { showingError = false }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskSheet(isPresented: $showingAddTask) { taskText in
                Task {
                    do {
                        try await taskService.addTask(to: list.id, text: taskText)
                    } catch {
                        showingError = true
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}

struct TaskRow: View {
    let task: Task
    let onToggle: (Task) -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: { onToggle(task) }) {
                ZStack {
                    if task.isCompleted {
                        Circle()
                            .fill(Color.accentBrand)
                            .frame(width: 10, height: 10)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.accentBrand, lineWidth: 0.5)
                            )
                    } else {
                        Circle()
                            .foregroundColor(.clear)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.accentBrand, lineWidth: 0.5)
                            )
                    }
                }
            }
            
            Text(task.text)
                .font(.montrealMedium(size: 16))
                .lineSpacing(24)
                .foregroundColor(.textPrimary)
                .strikethrough(task.isCompleted)
        }
        .scaleEffect(isPressed ? FeedbackService.Scale.taskCompletion : 1)
        .animation(FeedbackService.Animation.taskCompletion, value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            onToggle(task)
        }
    }
}

struct AddTaskSheet: View {
    @Binding var isPresented: Bool
    let onAdd: (String) -> Void
    @State private var taskText = ""
    @State private var isButtonPressed = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                TextField("Enter task", text: $taskText)
                    .font(.neueMontreal(size: 16))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    if !taskText.isEmpty {
                        FeedbackService.shared.triggerButtonPressHaptic()
                        onAdd(taskText)
                        isPresented = false
                    }
                }) {
                    Text("Add Task")
                        .font(.montrealMedium(size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentBrand)
                        .cornerRadius(10)
                }
                .disabled(taskText.isEmpty)
                .padding(.horizontal)
                .scaleEffect(isButtonPressed ? FeedbackService.Scale.buttonPress : 1)
                .animation(FeedbackService.Animation.buttonPress, value: isButtonPressed)
                .onTapGesture {
                    isButtonPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isButtonPressed = false
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Add New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        FeedbackService.shared.triggerSelectionHaptic()
                        isPresented = false
                    }
                }
            }
        }
    }
} 