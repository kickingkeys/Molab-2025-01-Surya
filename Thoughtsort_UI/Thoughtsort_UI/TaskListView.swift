//
//  TaskListView.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 21/04/25.
//

import SwiftUI

struct TaskListView: View {
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
                // Header
                VStack(alignment: .leading, spacing: 5) {
                    Text("Today's Tasks")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                    
                    Text("Edited on April 14, 2025, 10:07 PM")
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
                
                // Task list
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(tasks.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                // Task checkbox
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
                            .onTapGesture {
                                tasks[index].isCompleted.toggle()
                            }
                        }
                        
                        // Add task button
                        HStack(spacing: 8) {
                            ZStack {
                                Rectangle()
                                    .fill(ThemeColors.buttonLight)
                                    .frame(width: 16, height: 16)
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(ThemeColors.accent, lineWidth: 0.5)
                                    )
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 10))
                                    .foregroundColor(ThemeColors.accent)
                            }
                            
                            Text("Add more items")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.textDark)
                        }
                        .padding(.top, 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                }
                
                Spacer()
                
                // Footer text
                Text("Every list is archived at the end of the day, and you can find them in your archived tab.")
                    .font(.system(size: 14))
                    .italic()
                    .foregroundColor(ThemeColors.textDark.opacity(0.85))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 15)
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(ThemeColors.accent)
                            
                            Text("Go back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.accent)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                    }
                    .background(ThemeColors.background)
                    .cornerRadius(25)
                    
                    Button(action: {
                        // Archive action
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "archivebox")
                                .foregroundColor(ThemeColors.textDark)
                            
                            Text("Archive this list")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.textDark)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                    }
                    .background(ThemeColors.background)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(ThemeColors.textDark, lineWidth: 0.5)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

struct Task: Identifiable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}
