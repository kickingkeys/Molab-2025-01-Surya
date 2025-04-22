import SwiftUI

struct HomeView: View {
    @State private var taskText = ""
    @State private var isShowingTaskList = false
    @State private var showingArchive = false
    
    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Title and timestamp
                VStack(alignment: .leading, spacing: 5) {
                    Text("Create your To-Do List")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                    
                    Text("April 14, 2025, 10:07 PM")
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
                
                // Your Lists section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Lists for Today")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(ThemeColors.textDark)
                        .padding(.top, 30)
                    
                    // List item
                    Button(action: {
                        isShowingTaskList = true
                    }) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Grocery Day")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(ThemeColors.textDark)
                            
                            HStack(spacing: 4) {
                                Text("6 Items")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                                
                                Circle()
                                    .fill(Color(red: 0.46, green: 0.46, blue: 0.46))
                                    .frame(width: 4, height: 4)
                                
                                Text("4 Completed")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                                
                                Circle()
                                    .fill(Color(red: 0.46, green: 0.46, blue: 0.46))
                                    .frame(width: 4, height: 4)
                                
                                Text("Last edited 12:35 PM")
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
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Tab bar
                HStack(spacing: 0) {
                    // Home tab (left side - active)
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
                    Button(action: {
                        showingArchive = true
                    }) {
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
                    .navigationDestination(isPresented: $showingArchive) {
                        ArchiveView()
                    }
                }
                .cornerRadius(10)
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
