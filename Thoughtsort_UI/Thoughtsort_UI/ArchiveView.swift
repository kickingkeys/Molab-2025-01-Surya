import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
    @State private var selectedListIds: Set<String> = []
    @State private var isSelecting: Bool = false

    private var archiveDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ThemeColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Title
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("Archive")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(ThemeColors.textDark)

                                Spacer()

                                Button(action: {
                                    isSelecting.toggle()
                                    if !isSelecting { selectedListIds.removeAll() }
                                }) {
                                    Text(isSelecting ? "Cancel" : "Select")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(ThemeColors.accent)
                                }
                            }

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

                        // Archive List Items
                        if taskListViewModel.archivedLists.isEmpty {
                            Text("No archived lists yet.")
                                .foregroundColor(ThemeColors.textLight)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                        } else {
                            VStack(spacing: 10) {
                                ForEach(taskListViewModel.archivedLists) { list in
                                    if isSelecting {
                                        HStack(alignment: .top, spacing: 12) {
                                            Button(action: {
                                                if selectedListIds.contains(list.id) {
                                                    selectedListIds.remove(list.id)
                                                } else {
                                                    selectedListIds.insert(list.id)
                                                }
                                            }) {
                                                Image(systemName: selectedListIds.contains(list.id) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(ThemeColors.accent)
                                            }

                                            listContainer(for: list)
                                        }
                                        .padding(.horizontal, 20)
                                    } else {
                                        NavigationLink(destination: ArchivedListDetailView(listId: list.id)
                                            .environmentObject(taskListViewModel)) {
                                                listContainer(for: list)
                                                    .padding(.horizontal, 20)
                                        }
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }

                        Spacer(minLength: 30)
                    }
                }

                if isSelecting && !selectedListIds.isEmpty {
                    VStack {
                        Button(action: {
                            for id in selectedListIds {
                                taskListViewModel.deleteTaskList(listId: id)
                            }
                            selectedListIds.removeAll()
                            isSelecting = false
                        }) {
                            Text("Delete \(selectedListIds.count) Selected")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 10)
                    }
                }
            }
            .onAppear {
                taskListViewModel.listenToArchivedLists()
            }
        }
    }

    @ViewBuilder
    private func listContainer(for list: TaskList) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(list.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ThemeColors.textDark)

            HStack(spacing: 4) {
                Text("\(list.tasks.count) Items")
                Text("•")
                Text("\(list.completedCount) Completed")
                Text("•")
                Text("Created on \(archiveDateFormatter.string(from: list.createdAt))")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(ThemeColors.textLight)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ThemeColors.inputBackground)
        .cornerRadius(12)
    }
}
