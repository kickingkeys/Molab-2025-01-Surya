//
//  message.swift
//  Assignment_09simplechat
//
//  Created by Surya Narreddi on 07/04/25.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable {
    var id: String = UUID().uuidString
    var text: String
    var sender: String
    var timestamp: Date = Date()
    
    // For converting Firestore documents to Message objects
    static func from(dictionary: [String: Any]) -> Message? {
        guard let text = dictionary["text"] as? String,
              let sender = dictionary["sender"] as? String,
              let timestamp = dictionary["timestamp"] as? Timestamp else {
            return nil
        }
        
        var message = Message(text: text, sender: sender)
        message.id = dictionary["id"] as? String ?? UUID().uuidString
        message.timestamp = timestamp.dateValue()
        return message
    }
    
    // For converting Message objects to dictionaries for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "text": text,
            "sender": sender,
            "timestamp": Timestamp(date: timestamp)
        ]
    }
}
