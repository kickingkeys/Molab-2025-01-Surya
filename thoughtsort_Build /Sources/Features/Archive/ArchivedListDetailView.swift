import SwiftUI

struct TodoItem: Identifiable {
    let id = UUID()
    let title: String
    let isCompleted: Bool
}

struct ArchivedListDetailView: View {
    let title: String
    let createdDate: String
    @State private var items: [TodoItem] = [
        TodoItem(title: "Buy grocery from brooklyn bodega", isCompleted: false),
        TodoItem(title: "Get beard trimmed", isCompleted: true),
        TodoItem(title: "Crib about Figma's new UI", isCompleted: false),
        TodoItem(title: "Complete project for this semester", isCompleted: false),
        TodoItem(title: "Touch grass", isCompleted: false)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.94, green: 0.94, blue: 0.92)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                // Header with back button
                HStack(spacing: 16) {
                    Button(action: { /* Handle back navigation */ }) {
                        PhosphorIconView(.arrowLeft)
                            .frame(width: 32, height: 32)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.editorialNewRegular(size: 28))
                            .lineSpacing(33.60)
                            .foregroundColor(.textPrimary)
                        
                        Text("Created on \(createdDate)")
                            .font(.neueMontreal(size: 14))
                            .lineSpacing(21)
                            .foregroundColor(.textPrimary)
                    }
                }
                .padding(.top, 64)
                
                // Todo Items List
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(items) { item in
                        HStack(spacing: 8) {
                            // Checkbox
                            ZStack {
                                Circle()
                                    .strokeBorder(Color(red: 0.93, green: 0.41, blue: 0.17), lineWidth: 0.5)
                                    .frame(width: 16, height: 16)
                                
                                if item.isCompleted {
                                    Circle()
                                        .fill(Color(red: 0.93, green: 0.41, blue: 0.17))
                                        .frame(width: 10, height: 10)
                                }
                            }
                            
                            // Task Text
                            Text(item.title)
                                .font(.montrealMedium(size: 16))
                                .lineSpacing(24)
                                .foregroundColor(.textPrimary)
                                .strikethrough(item.isCompleted)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ArchivedListDetailView(
        title: "Grocery Day",
        createdDate: "April 14, 2025"
    )
} 