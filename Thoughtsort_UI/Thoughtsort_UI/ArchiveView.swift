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
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                    }
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
