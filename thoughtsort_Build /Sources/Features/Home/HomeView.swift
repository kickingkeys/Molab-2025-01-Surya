import SwiftUI
import Speech

struct HomeView: View {
    @StateObject private var speechRecognition = SpeechRecognitionService()
    @StateObject private var taskService = TaskService()
    @State private var inputText = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isProcessing = false
    @State private var selectedTab: Tab = .home
    
    private enum Tab {
        case home
        case archive
    }
    
    private func handleRecordButton() {
        if speechRecognition.isRecording {
            speechRecognition.stopRecording()
            inputText = speechRecognition.transcribedText
        } else {
            speechRecognition.startRecording()
        }
    }
    
    private func handleOrganize() {
        guard !inputText.isEmpty else { return }
        
        isProcessing = true
        Task {
            do {
                // Use AI to organize thoughts into tasks
                let tasks = try await ThoughtOrganizationService.shared.organizeThoughts(inputText)
                
                // Create a new list with the organized tasks
                try await taskService.createTaskList(
                    title: "Organized Tasks",
                    tasks: tasks
                )
                
                // Clear input after successful creation
                DispatchQueue.main.async {
                    inputText = ""
                    isProcessing = false
                }
            } catch {
                DispatchQueue.main.async {
                    showingError = true
                    errorMessage = error.localizedDescription
                    isProcessing = false
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if selectedTab == .home {
                    ZStack {
                        Color.backgroundPrimary
                            .ignoresSafeArea()
                        
                        VStack(alignment: .leading, spacing: 24) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Create your To-Do List")
                                    .font(.editorialNewRegular(size: 28))
                                    .lineSpacing(33.60)
                                    .foregroundColor(.textPrimary)
                                
                                Text(Date().formatted(date: .long, time: .shortened))
                                    .font(.neueMontreal(size: 14))
                                    .lineSpacing(21)
                                    .foregroundColor(.textPrimary)
                            }
                            .padding(.top, 64)
                            
                            // Input Area
                            TextEditor(text: $inputText)
                                .font(.neueMontreal(size: 14))
                                .lineSpacing(21)
                                .foregroundColor(.textPrimary)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color.inputBackground)
                                .cornerRadius(12)
                                .overlay(
                                    Group {
                                        if inputText.isEmpty {
                                            Text("Feeling overwhelmed? Type everything you need to do here, and I'll help organise your thoughts...")
                                                .font(.neueMontreal(size: 14))
                                                .lineSpacing(21)
                                                .foregroundColor(.textSecondary)
                                                .padding(12)
                                        }
                                    }
                                )
                            
                            // Action Buttons
                            HStack(spacing: 12) {
                                Button(action: handleRecordButton) {
                                    HStack(spacing: 8) {
                                        PhosphorIconView(.microphone)
                                            .foregroundColor(speechRecognition.isRecording ? .accentBrand : .textPrimary)
                                        Text("Record")
                                            .font(.montrealMedium(size: 16))
                                            .lineSpacing(19.20)
                                            .foregroundColor(.textPrimary)
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 51)
                                    .background(Color.backgroundPrimary)
                                    .cornerRadius(100)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 100)
                                            .stroke(Color.textPrimary, lineWidth: 0.5)
                                    )
                                }
                                
                                Button(action: {
                                    FeedbackService.shared.triggerButtonPressHaptic()
                                    handleOrganize()
                                }) {
                                    HStack(spacing: 8) {
                                        if isProcessing {
                                            LoadingIndicator()
                                                .frame(width: 24, height: 24)
                                        } else {
                                            PhosphorIconView(.magicWand)
                                        }
                                        Text("Organize")
                                            .font(.montrealMedium(size: 16))
                                            .lineSpacing(19.20)
                                            .foregroundColor(Color.backgroundPrimary)
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(height: 51)
                                    .background(Color.accentBrand)
                                    .cornerRadius(100)
                                    .opacity(inputText.isEmpty ? 0.5 : 1)
                                }
                                .disabled(inputText.isEmpty || isProcessing)
                            }
                            
                            // Lists Section
                            if !taskService.currentLists.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Your Lists for Today")
                                        .font(.editorialNewRegular(size: 28))
                                        .lineSpacing(33.60)
                                        .foregroundColor(.textPrimary)
                                    
                                    ForEach(taskService.currentLists) { list in
                                        NavigationLink(destination: TaskListView(list: list)) {
                                            TodoListRow(list: list)
                                        }
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Custom Tab Bar
                            HStack(spacing: 0) {
                                TabButton(
                                    icon: .house,
                                    title: "Home",
                                    isSelected: selectedTab == .home,
                                    action: { selectedTab = .home }
                                )
                                
                                TabButton(
                                    icon: .archiveBox,
                                    title: "Archive",
                                    isSelected: selectedTab == .archive,
                                    action: { selectedTab = .archive }
                                )
                            }
                            .background(Color.inputBackground)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        }
                        .padding(.horizontal, 20)
                    }
                } else {
                    ArchiveView()
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { showingError = false }
        } message: {
            Text(errorMessage)
        }
        .task {
            // Setup automatic archiving when the app starts
            taskService.setupAutomaticArchiving()
            await taskService.loadTodayLists()
        }
    }
}

struct TodoListRow: View {
    let list: TaskList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(list.title)
                .font(.montrealMedium(size: 16))
                .lineSpacing(24)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 4) {
                Text("\(list.taskCount) Items")
                    .font(.montrealMedium(size: 12))
                    .lineSpacing(18)
                    .foregroundColor(.textSecondary)
                
                Circle()
                    .fill(Color.textSecondary)
                    .frame(width: 4, height: 4)
                
                Text("\(list.completedCount) Completed")
                    .font(.montrealMedium(size: 12))
                    .lineSpacing(18)
                    .foregroundColor(.textSecondary)
                
                Circle()
                    .fill(Color.textSecondary)
                    .frame(width: 4, height: 4)
                
                Text("Last edited \(list.lastEditedAt.formatted(date: .omitted, time: .shortened))")
                    .font(.montrealMedium(size: 12))
                    .lineSpacing(18)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.inputBackground)
        .cornerRadius(12)
    }
}

struct TabButton: View {
    let icon: PhosphorIcon
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                PhosphorIconView(icon)
                    .foregroundColor(isSelected ? .accentBrand : .textPrimary)
                
                Text(title)
                    .font(.montrealMedium(size: 12))
                    .foregroundColor(isSelected ? .accentBrand : .textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    HomeView()
} 