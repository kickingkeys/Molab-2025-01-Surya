import SwiftUI

struct ArchivedListDetailView: View {
    var listId: String
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var taskList: TaskList? {
        taskListViewModel.archivedLists.first(where: { $0.id == listId })
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    var body: some View {
        ZStack {
            ThemeColors.background.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(ThemeColors.textDark)
                    }
                    Text("Back")
                        .font(.system(size: 16))
                        .foregroundColor(ThemeColors.textDark)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Title and date
                if let list = taskList {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(list.title)
                            .font(ThemeTypography.titleLarge)
                            .foregroundColor(ThemeColors.textDark)
                        
                        Text("Created on \(dateFormatter.string(from: list.createdAt))")
                            .font(ThemeTypography.caption)
                            .foregroundColor(ThemeColors.textLight)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                // Dashed divider
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
                
                // Task list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        if let list = taskList {
                            ForEach(list.tasks) { task in
                                HStack(spacing: 10) {
                                    ZStack {
                                        Circle()
                                            .strokeBorder(ThemeColors.accent, lineWidth: 1)
                                            .frame(width: 18, height: 18)
                                        if task.isCompleted {
                                            Circle()
                                                .fill(ThemeColors.accent)
                                                .frame(width: 10, height: 10)
                                        }
                                    }
                                    
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
