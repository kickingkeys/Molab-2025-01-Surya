import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDetailView = false
    @State private var selectedListId: String = ""
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Title and count
                VStack(alignment: .leading, spacing: 5) {
                    Text("Archive")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                    
                    Text("\(taskListViewModel.archivedLists.count) List items")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textDark)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.top, 10)
                
                // Archived lists
                ScrollView {
                    if taskListViewModel.isLoading {
                        ProgressView()
                            .padding()
                    } else if taskListViewModel.archivedLists.isEmpty {
                        Text("No archived lists yet.")
                            .foregroundColor(ThemeColors.textLight)
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(taskListViewModel.archivedLists) { list in
                                Button(action: {
                                    selectedListId = list.id
                                    showDetailView = true
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(list.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(ThemeColors.textDark)
                                        
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "MMMM d, yyyy"
                                        
                                        HStack(spacing: 4) {
                                            Text("\(list.tasks.count) Items")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                                            
                                            Circle()
                                                .fill(Color(red: 0.46, green: 0.46, blue: 0.46))
                                                .frame(width: 4, height: 4)
                                            
                                            Text("\(list.completedCount) Completed")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                                            
                                            Circle()
                                                .fill(Color(red: 0.46, green: 0.46, blue: 0.46))
                                                .frame(width: 4, height: 4)
                                            
                                            Text("Created on \(dateFormatter.string(from: list.createdAt))")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                                        }
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
                    .padding(.top, 15)
                }
                
                Spacer()
                
                // Tab bar
                HStack(spacing: 0) {
                    // Home tab (left side)
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            VStack(spacing: 5) {
                                Image(systemName: "house.fill")
                                    .foregroundColor(ThemeColors.textDark)
                                Text("Home")
                                    .font(.system(size: 12))
                                    .foregroundColor(ThemeColors.textDark)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(ThemeColors.inputBackground)
                    }
                    
                    // Archive tab (right side - active)
                    HStack {
                        Spacer()
                        VStack(spacing: 5) {
                            Image(systemName: "archivebox.fill")
                                .foregroundColor(ThemeColors.accent)
                            Text("Archive")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.accent)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(ThemeColors.buttonLight)
                }
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showDetailView) {
            ArchivedListDetailView(listId: selectedListId)
        }
        .onAppear {
            taskListViewModel.loadArchivedLists()
        }
        .refreshable {
            taskListViewModel.loadArchivedLists()
        }
    }
}

// Update ArchivedListDetailView to use real data
struct ArchivedListDetailView: View {
    var listId: String
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var taskList: TaskList? {
        taskListViewModel.archivedLists.first(where: { $0.id == listId })
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
                if let list = taskList {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(list.title)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(ThemeColors.textDark)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMMM d, yyyy"
                        Text("Created on \(dateFormatter.string(from: list.createdAt))")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textDark)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.top, 10)
                
                // Task list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let list = taskList {
                            ForEach(list.tasks) { task in
                                HStack(spacing: 8) {
                                    // Non-interactive checkbox
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
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
