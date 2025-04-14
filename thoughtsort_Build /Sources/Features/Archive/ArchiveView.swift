import SwiftUI

struct ArchiveView: View {
    @EnvironmentObject private var taskService: TaskService
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private var groupedLists: [(String, [TaskList])] {
        let calendar = Calendar.current
        
        // Group lists by date
        let grouped = Dictionary(grouping: taskService.archivedLists) { list in
            calendar.startOfDay(for: list.archivedAt ?? list.createdAt)
        }
        
        // Sort by date (most recent first) and format the date
        return grouped.map { (date, lists) in
            (date.formatted(date: .long, time: .omitted), lists)
        }.sorted { $0.0 > $1.0 }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundPrimary
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Archive")
                            .font(.editorialNewRegular(size: 28))
                            .lineSpacing(33.60)
                            .foregroundColor(.textPrimary)
                        
                        Text("\(taskService.archivedLists.count) List\(taskService.archivedLists.count == 1 ? "" : "s")")
                            .font(.neueMontreal(size: 14))
                            .lineSpacing(21)
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.top, 64)
                    
                    if taskService.archivedLists.isEmpty {
                        VStack(spacing: 8) {
                            Text("No archived lists yet")
                                .font(.montrealMedium(size: 16))
                                .foregroundColor(.textPrimary)
                            
                            Text("Lists are automatically archived at midnight")
                                .font(.neueMontreal(size: 14))
                                .foregroundColor(.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Archived Lists
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 24) {
                                ForEach(groupedLists, id: \.0) { date, lists in
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(date)
                                            .font(.montrealMedium(size: 14))
                                            .foregroundColor(.textSecondary)
                                        
                                        ForEach(lists) { list in
                                            NavigationLink(destination: TaskListView(list: list)) {
                                                ArchivedListRow(list: list)
                                            }
                                        }
                                    }
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
                            isSelected: false,
                            action: { /* Home tab action */ }
                        )
                        
                        TabButton(
                            icon: .archiveBox,
                            title: "Archive",
                            isSelected: true,
                            action: { /* Archive tab action */ }
                        )
                    }
                    .background(Color.inputBackground)
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 20)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { showingError = false }
        } message: {
            Text(errorMessage)
        }
        .task {
            await taskService.loadArchivedLists()
        }
    }
}

struct ArchivedListRow: View {
    let list: TaskList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
                
                Text("Created on \((list.archivedAt ?? list.createdAt).formatted(date: .abbreviated, time: .shortened))")
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

#Preview {
    ArchiveView()
} 