import SwiftUI


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
                        
                        let dateFormatter: DateFormatter = {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .long
                            return formatter
                        }()
                        Text("Created on \(dateFormatter.string(from: list.createdAt))")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textDark)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("List Details")
                            .font(.system(size: 28, weight: .medium))
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

// Remove any other ArchivedListDetailView definitions in your project
