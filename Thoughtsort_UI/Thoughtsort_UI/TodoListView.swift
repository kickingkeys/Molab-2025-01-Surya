import SwiftUI

@State private var isShowingTaskList = false

struct TodoListView: View {
    @State private var taskText = ""
    @State private var currentDate = Date()
    @Environment(\.dismiss) private var dismiss
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy, h:mm a"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header with single back button
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
                    Text("Create your To-Do List")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                    
                    Text(dateFormatter.string(from: currentDate))
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
                
                // Input area
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $taskText)
                        .padding()
                        .background(ThemeColors.inputBackground)
                        .cornerRadius(12)
                        .frame(height: 120)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    if taskText.isEmpty {
                        Text("Feeling overwhelmed? Type everything you need to do here, and I'll help organise your thoughts...")
                            .font(.system(size: 14))
                            .foregroundColor(ThemeColors.textLight)
                            .padding(.horizontal, 36)
                            .padding(.top, 36)
                            .allowsHitTesting(false)
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "mic.fill")
                                .foregroundColor(ThemeColors.textDark)
                            Text("Record")
                                .foregroundColor(ThemeColors.textDark)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(ThemeColors.background)
                        .cornerRadius(25)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(ThemeColors.textDark.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        isShowingTaskList = true
                    }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.white)
                            Text("Organize")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(ThemeColors.accent)
                        .cornerRadius(25)
                    }
                    .navigationDestination(isPresented: $isShowingTaskList) {
                        TaskListView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                
                Spacer()
                
                // Tab bar - fixing the full width issue
                HStack(spacing: 0) {
                    // Home tab (left side)
                    HStack {
                        Spacer()
                        VStack(spacing: 5) {
                            Image(systemName: "house.fill")
                                .foregroundColor(ThemeColors.accent)
                            Text("Home")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.accent)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(ThemeColors.buttonLight)
                    
                    // Archive tab (right side)
                    HStack {
                        Spacer()
                        VStack(spacing: 5) {
                            Image(systemName: "archivebox")
                                .foregroundColor(ThemeColors.textDark)
                            Text("Archive")
                                .font(.system(size: 12))
                                .foregroundColor(ThemeColors.textDark)
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(ThemeColors.inputBackground.opacity(0.5))
                }
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            }
        }
        .onAppear {
            currentDate = Date()
        }
    }
}
