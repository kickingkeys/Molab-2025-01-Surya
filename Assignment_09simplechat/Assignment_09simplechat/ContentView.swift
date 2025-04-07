//
//  ContentView.swift
//  Assignment_09simplechat
//
//  Created by Surya Narreddi on 07/04/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var chatService = ChatService()
    @State private var messageText = ""
    @State private var userName = "User" // Simple username
    
    var body: some View {
        VStack {
            // Messages list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(chatService.messages) { message in
                        MessageBubble(message: message, isCurrentUser: message.sender == userName)
                    }
                }
                .padding()
            }
            
            // Error message display
            if let errorMessage = chatService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Message input
            HStack {
                TextField("Type a message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: sendMessage) {
                    Text("Send")
                        .padding(.horizontal)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Simple Chat")
    }
    
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        chatService.sendMessage(text: messageText, sender: userName)
        messageText = ""
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading) {
                Text(message.sender)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(message.text)
                    .padding(10)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(10)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}

#Preview {
    ContentView()
}
