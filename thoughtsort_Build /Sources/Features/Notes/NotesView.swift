import SwiftUI

struct Task: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool
}

struct NotesView: View {
    @State private var tasks: [Task] = [
        Task(title: "Buy grocery from brooklyn bodega", isCompleted: false),
        Task(title: "Get beard trimmed", isCompleted: true),
        Task(title: "Crib about Figma's new UI", isCompleted: false),
        Task(title: "Complete project for this semester", isCompleted: false),
        Task(title: "Touch grass", isCompleted: false)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Tasks")
                        .font(.editorialNewRegular(size: 28))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(33.60)
                    
                    Text("Edited on April 14, 2025, 10:07 PM")
                        .font(.neueMontreal(size: 14))
                        .foregroundColor(.textPrimary)
                        .lineSpacing(21)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 64)
                
                // Task List
                VStack(alignment: .leading, spacing: 12) {
                    ForEach($tasks) { $task in
                        TaskRow(task: $task)
                    }
                    
                    // Add more items button
                    Button(action: { /* Add new task */ }) {
                        HStack(spacing: 8) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 16, height: 16)
                                    .background(Color(red: 0.94, green: 0.86, blue: 0.80))
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.accentBrand, lineWidth: 0.5)
                                    )
                            }
                            
                            Text("Add more items")
                                .font(.montrealMedium(size: 16))
                                .foregroundColor(.textPrimary)
                                .lineSpacing(24)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Footer note
                Text("Every list is archived at the end of the day, and you can find them in your archived tab.")
                    .font(.neueMontreal(size: 14))
                    .italic()
                    .foregroundColor(.textPrimary.opacity(0.85))
                    .lineSpacing(21)
                    .padding(.horizontal, 20)
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: { /* Go back */ }) {
                        HStack(spacing: 8) {
                            PhosphorIconView(.arrowLeft)
                            Text("Go back")
                                .font(.montrealMedium(size: 16))
                                .lineSpacing(19.20)
                        }
                        .foregroundColor(.accentBrand)
                        .padding(.horizontal, 16)
                        .frame(height: 51)
                        .background(Color.inputBackground)
                        .cornerRadius(100)
                    }
                    
                    Button(action: { /* Archive list */ }) {
                        HStack(spacing: 8) {
                            PhosphorIconView(.archiveBox)
                            Text("Archive this list")
                                .font(.montrealMedium(size: 16))
                                .lineSpacing(19.20)
                        }
                        .foregroundColor(.textPrimary)
                        .padding(.horizontal, 16)
                        .frame(height: 51)
                        .background(Color.inputBackground)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.textPrimary, lineWidth: 0.5)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
        }
    }
}

struct TaskRow: View {
    @Binding var task: Task
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: { task.isCompleted.toggle() }) {
                ZStack {
                    if task.isCompleted {
                        Circle()
                            .fill(Color.accentBrand)
                            .frame(width: 10, height: 10)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.accentBrand, lineWidth: 0.5)
                            )
                    } else {
                        Circle()
                            .foregroundColor(.clear)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.accentBrand, lineWidth: 0.5)
                            )
                    }
                }
            }
            
            Text(task.title)
                .font(.montrealMedium(size: 16))
                .lineSpacing(24)
                .foregroundColor(.textPrimary)
                .strikethrough(task.isCompleted)
        }
    }
}

#Preview {
    NotesView()
} 