import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @State private var selectedListId: String?

    // Formatter moved out of view hierarchy
    private var archiveDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ThemeColors.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Title
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Archive")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(ThemeColors.textDark)

                        Text("\(taskListViewModel.archivedLists.count) List item\(taskListViewModel.archivedLists.count == 1 ? "" : "s")")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textDark)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    // Dashed Divider
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

                    // List of Archived Items
                    if taskListViewModel.archivedLists.isEmpty {
                        Text("No archived lists yet.")
                            .foregroundColor(ThemeColors.textLight)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                        Spacer()
                    } else {
                        List {
                            ForEach(taskListViewModel.archivedLists) { list in
                                NavigationLink(value: list.id) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(list.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(ThemeColors.textDark)

                                        HStack(spacing: 4) {
                                            Text("\(list.tasks.count) Items")
                                            Circle().frame(width: 4, height: 4)
                                            Text("\(list.completedCount) Completed")
                                            Circle().frame(width: 4, height: 4)
                                            Text("Created on \(archiveDateFormatter.string(from: list.createdAt))")
                                        }
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(ThemeColors.textLight)
                                    }
                                    .padding(.vertical, 8)
                                }
                                .swipeActions {
                                    Button(role: .destructive) {
                                        taskListViewModel.deleteTaskList(listId: list.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                            .listRowBackground(ThemeColors.inputBackground)
                        }
                        .listStyle(.plain)
                        .padding(.top, 10)
                    }
                }
            }
            .navigationDestination(for: String.self) { listId in
                ArchivedListDetailView(listId: listId)
                    .environmentObject(taskListViewModel)
            }
            .onAppear {
                taskListViewModel.listenToArchivedLists()
            }
        }
    }
}
