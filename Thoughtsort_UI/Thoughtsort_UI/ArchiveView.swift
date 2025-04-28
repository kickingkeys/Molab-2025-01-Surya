import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject private var taskListViewModel: TaskListViewModel
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

                    Text("\(taskListViewModel.archivedLists.count) List item\(taskListViewModel.archivedLists.count == 1 ? "" : "s")")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textDark)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                // Divider
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

                // Archived lists
                ScrollView {
                    if taskListViewModel.archivedLists.isEmpty {
                        Text("No archived lists yet.")
                            .foregroundColor(ThemeColors.textLight)
                            .padding()
                    } else {
                        VStack(spacing: 12) {
                            ForEach(taskListViewModel.archivedLists) { list in
                                let dateFormatter: DateFormatter = {
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "MMMM d, yyyy"
                                    return formatter
                                }()

                                Button(action: {
                                    selectedListId = list.id
                                    showDetailView = true
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(list.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(ThemeColors.textDark)

                                        HStack(spacing: 4) {
                                            Text("\(list.tasks.count) Items")
                                            Circle()
                                                .frame(width: 4, height: 4)
                                            Text("\(list.completedCount) Completed")
                                            Circle()
                                                .frame(width: 4, height: 4)
                                            Text("Created on \(dateFormatter.string(from: list.createdAt))")
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
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showDetailView) {
            ArchivedListDetailView(listId: selectedListId)
        }
        .onAppear {
            taskListViewModel.listenToArchivedLists()
        }
    }
}
