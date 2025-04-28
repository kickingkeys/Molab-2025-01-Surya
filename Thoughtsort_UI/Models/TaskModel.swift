//
//  TaskModel.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 27/04/25.
//

import Foundation
import FirebaseFirestore

struct Task: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isCompleted
        case createdAt
    }
}
