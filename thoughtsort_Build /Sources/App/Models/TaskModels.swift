import Foundation
import FirebaseFirestore

struct Task: Identifiable, Codable {
    var id: String
    var listId: String
    var text: String
    var isCompleted: Bool
    var createdAt: Date
    var completedAt: Date?
    var order: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case listId
        case text
        case isCompleted
        case createdAt
        case completedAt
        case order
    }
}

struct TaskList: Identifiable, Codable {
    var id: String
    var userId: String
    var title: String
    var createdAt: Date
    var lastEditedAt: Date
    var isArchived: Bool
    var taskCount: Int
    var completedCount: Int
    var archivedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case createdAt
        case lastEditedAt
        case isArchived
        case taskCount
        case completedCount
        case archivedAt
    }
}

// Extensions for Firestore compatibility
extension Task {
    init(from document: DocumentSnapshot) throws {
        let data = document.data() ?? [:]
        
        self.id = document.documentID
        self.listId = data["listId"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.isCompleted = data["isCompleted"] as? Bool ?? false
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.completedAt = (data["completedAt"] as? Timestamp)?.dateValue()
        self.order = data["order"] as? Int ?? 0
    }
    
    var firestoreData: [String: Any] {
        return [
            "listId": listId,
            "text": text,
            "isCompleted": isCompleted,
            "createdAt": Timestamp(date: createdAt),
            "completedAt": completedAt.map { Timestamp(date: $0) },
            "order": order
        ]
    }
}

extension TaskList {
    init(from document: DocumentSnapshot) throws {
        let data = document.data() ?? [:]
        
        self.id = document.documentID
        self.userId = data["userId"] as? String ?? ""
        self.title = data["title"] as? String ?? ""
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
        self.lastEditedAt = (data["lastEditedAt"] as? Timestamp)?.dateValue() ?? Date()
        self.isArchived = data["isArchived"] as? Bool ?? false
        self.taskCount = data["taskCount"] as? Int ?? 0
        self.completedCount = data["completedCount"] as? Int ?? 0
        self.archivedAt = (data["archivedAt"] as? Timestamp)?.dateValue()
    }
    
    var firestoreData: [String: Any] {
        var data: [String: Any] = [
            "userId": userId,
            "title": title,
            "createdAt": Timestamp(date: createdAt),
            "lastEditedAt": Timestamp(date: lastEditedAt),
            "isArchived": isArchived,
            "taskCount": taskCount,
            "completedCount": completedCount
        ]
        
        if let archivedAt = archivedAt {
            data["archivedAt"] = Timestamp(date: archivedAt)
        }
        
        return data
    }
} 