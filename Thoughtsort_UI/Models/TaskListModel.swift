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
    var tasks: [Task] = []
    var createdAt: Date = Date()
    var isArchived: Bool = false
    var userId: String

    var itemCount: Int {
        tasks.count
    }
    
    var completedCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
}
