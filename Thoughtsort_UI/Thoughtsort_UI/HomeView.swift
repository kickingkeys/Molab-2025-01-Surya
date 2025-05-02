import SwiftUI
import FirebaseAuth
import Speech
import AVFoundation

struct HomeView: View {
    @EnvironmentObject var userSessionManager: UserSessionManager
    @EnvironmentObject var taskListViewModel: TaskListViewModel

    @State private var taskText = ""
    @State private var showSettings = false
    @State private var isRecording = false
    @State private var audioEngine = AVAudioEngine()
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?

    @State private var showShortInputAlert = false
    @State private var showClaudeErrorAlert = false
    @State private var navigateToListID: String?

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    headerView
                    dividerView
                    inputArea
                    actionButtons
                    listsSection
                }
            }
            .onAppear {
                taskListViewModel.loadActiveLists()
                requestSpeechAuthorization()
            }
            .navigationDestination(for: String.self) { listId in
                TaskListView(taskListId: listId)
                    .environmentObject(taskListViewModel)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .alert("Stop wasting tokens!", isPresented: $showShortInputAlert) {
                Button("I'll do better", role: .cancel) { }
            } message: {
                Text("Just type that.")
            }
            .alert("Claude Error", isPresented: $showClaudeErrorAlert, actions: {
                Button("I'll try again", role: .cancel) { }
            }, message: {
                Text(taskListViewModel.claudeErrorMessage ?? "Something went wrong.")
            })
            .onChange(of: taskListViewModel.claudeErrorMessage) { newValue in
                if newValue != nil {
                    showClaudeErrorAlert = true
                }
            }
        }
    }

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Create your To-Do List")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(ThemeColors.textDark)

                HStack(spacing: 4) {
                    Text(Date(), style: .date)
                    Text("•")
                    Text(Date(), style: .time)
                }
                .font(.system(size: 14))
                .foregroundColor(ThemeColors.textDark)
            }

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundColor(ThemeColors.textDark)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var dividerView: some View {
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
    }

    private var inputArea: some View {
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
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
                isRecording.toggle()
            }) {
                HStack {
                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.fill")
                        .foregroundColor(ThemeColors.textDark)
                    Text(isRecording ? "Stop" : "Record")
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
                let trimmed = taskText.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count < 30 {
                    showShortInputAlert = true
                } else {
                    let title = formattedNewTaskListTitle()
                    let newList = TaskList(title: title, userId: Auth.auth().currentUser?.uid ?? "unknown_user")
                    navigateToListID = newList.id
                    print("🟠 Navigating to new list ID: \(newList.id)")
                    taskListViewModel.generateTaskListFromInput(input: trimmed, title: title, idOverride: newList.id)
                    taskText = ""
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
                .background(ThemeColors.accent)
                .cornerRadius(100)
                .opacity(taskText.isEmpty ? 0.5 : 1)
            }
            .disabled(taskText.isEmpty)
            .navigationDestination(for: String.self) { id in
                TaskListView(taskListId: id)
                    .environmentObject(taskListViewModel)
            }
            .onChange(of: navigateToListID) { id in
                if let id = id {
                    print("✅ Trigger navigation to \(id)")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .background(
            NavigationLink("", tag: navigateToListID ?? "", selection: $navigateToListID) {
                if let id = navigateToListID {
                    TaskListView(taskListId: id)
                        .environmentObject(taskListViewModel)
                }
            }
            .opacity(0)
        )
    }

    private var listsSection: some View {
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
                            .listRowBackground(ThemeColors.background)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button {
                                    taskListViewModel.archiveTaskList(list.id)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        taskListViewModel.loadActiveLists()
                                    }
                                } label: {
                                    Label("Archive", systemImage: "archivebox")
                                }
                                .tint(.orange)
                            }
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(ThemeColors.background)
            }
        }
    }

    private func formattedNewTaskListTitle() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "Tasks • \(formatter.string(from: Date()))"
    }

    private func formattedTaskListTitle(list: TaskList) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return "Tasks • \(formatter.string(from: list.createdAt))"
    }

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus != .authorized {
                print("Speech recognition authorization failed")
            }
        }
    }

    private func startRecording() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.taskText = result.bestTranscription.formattedString
                }
            } else if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.finish()
        recognitionTask = nil
    }
}
