//
//  ArchivedListDetailView.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 21/04/25.
//

import SwiftUI

struct ArchivedListDetailView: View {
    let listTitle: String
    let creationDate: String
    @State private var tasks = [
        Task(title: "Buy grocery from brooklyn bodega", isCompleted: false),
        Task(title: "Get beard trimmed", isCompleted: true),
        Task(title: "Crib about Figma's new UI", isCompleted: false),
        Task(title: "Complete project for this semester", isCompleted: false),
        Task(title: "Touch grass", isCompleted: false)
    ]
    @Environment(\.dismiss) private var dismiss
    
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
                VStack(alignment: .leading, spacing: 5) {
                    Text(listTitle)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                    
                    Text("Created on \(creationDate)")
                        .font(.system(size: 14))
                        .foregroundColor(ThemeColors.textDark)
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 1)
                    .padding(.top, 10)
                
                // Task list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(tasks.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                // Task checkbox (non-interactive in archive view)
                                if tasks[index].isCompleted {
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
                                Text(tasks[index].title)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(ThemeColors.textDark)
                                    .strikethrough(tasks[index].isCompleted)
                            }
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

struct ArchivedListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedListDetailView(listTitle: "Grocery Day", creationDate: "April 14, 2025")
    }
}
