//
//  TaskListModel.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 27/04/25.
//

import Foundation
import FirebaseFirestore

struct TaskList: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var tasks: [Task]
    var createdAt: Date
    var isArchived: Bool = false
    var userId: String
    
    // Computed properties
    var itemCount: Int {
        return tasks.count
    }
    
    var completedCount: Int {
        return tasks.filter { $0.isCompleted }.count
    }
}
