import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var userSessionManager: UserSessionManager
    @State private var taskText = ""
    @State private var isShowingTaskList = false
    @State private var isShowingSettings = false
    @State private var taskLists: [TaskList] = []
    @State private var isLoadingTasks = true

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Title and settings icon
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Create your To-Do List")
                                .font(.system(size: 28, weight: .medium))
                                .foregroundColor(ThemeColors.textDark)
                            
                            HStack {
                                Text(Date(), style: .date)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textDark)  // Apply color to the date part
                                Text(".")
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textDark)  // Apply color to the comma part
                                Text(Date(), style: .time)
                                    .font(.system(size: 14))
                                    .foregroundColor(ThemeColors.textDark)  // Apply color to the time part
                            }

                        }

                        Spacer()

                        Button(action: {
                            isShowingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(ThemeColors.textDark)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Dotted line divider
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
                        Button(action: {
                            // Placeholder for Record action
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

                    // Task Lists Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Lists for Today")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(ThemeColors.textDark)
                            .padding(.top, 30)

                        if isLoadingTasks {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else if taskLists.isEmpty {
                            Text("No task lists found. Start by creating one!")
                                .font(.system(size: 16))
                                .foregroundColor(ThemeColors.textLight)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            ForEach(taskLists) { list in
                                Button(action: {
                                    isShowingTaskList = true
                                }) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(list.title)
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
                                        .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(ThemeColors.inputBackground)
                                    .cornerRadius(12)
                                }
                            }
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
            .onAppear {
                fetchTaskLists()
            }
        }
    }

    private func fetchTaskLists() {
        isLoadingTasks = true
        FirestoreManager().getTaskLists(archived: false) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let lists):
                    self.taskLists = lists
                case .failure(let error):
                    print("Error fetching task lists: \(error.localizedDescription)")
                }
                isLoadingTasks = false
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(UserSessionManager())
    }
}
