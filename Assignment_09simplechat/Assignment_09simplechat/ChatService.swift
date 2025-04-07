//
//  ChatService.swift
//  Assignment_09simplechat
//
//  Created by Surya Narreddi on 07/04/25.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

class ChatService: ObservableObject {
    @Published var messages: [Message] = []
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    init() {
        fetchMessages()
    }
    
    func fetchMessages() {
        listenerRegistration = db.collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error fetching messages: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No documents found"
                    return
                }
                
                self.messages = documents.compactMap { document in
                    let data = document.data()
                    return Message.from(dictionary: data)
                }
            }
    }
    
    func sendMessage(text: String, sender: String) {
        let message = Message(text: text, sender: sender)
        
        db.collection("messages").document(message.id).setData(message.toDictionary()) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error sending message: \(error.localizedDescription)"
            }
        }
    }
    
    deinit {
        listenerRegistration?.remove()
    }
}
