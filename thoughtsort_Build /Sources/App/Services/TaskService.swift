import Foundation
import FirebaseFirestore
import FirebaseAuth

class TaskService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var currentLists: [TaskList] = []
    @Published var archivedLists: [TaskList] = []
    @Published var currentTasks: [String: [Task]] = [:] // Dictionary of listId: [Task]
    @Published var error: Error?
    
    // MARK: - Task List Operations
    
    func createTaskList(title: String, tasks: [String]) async throws -> TaskList {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AuthError.notAuthenticated
        }
        
        let newList = TaskList(
            id: UUID().uuidString,
            userId: userId,
            title: title,
            createdAt: Date(),
            lastEditedAt: Date(),
            isArchived: false,
            taskCount: tasks.count,
            completedCount: 0,
            archivedAt: nil
        )
        
        // Create the list document
        try await db.collection("taskLists").document(newList.id).setData(newList.firestoreData)
        
        // Create tasks
        for (index, taskText) in tasks.enumerated() {
            let task = Task(
                id: UUID().uuidString,
                listId: newList.id,
                text: taskText,
                isCompleted: false,
                createdAt: Date(),
                completedAt: nil,
                order: index
            )
            
            try await db.collection("tasks").document(task.id).setData(task.firestoreData)
        }
        
        await loadTodayLists()
        return newList
    }
    
    func getTodayLists() async throws -> [TaskList] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AuthError.notAuthenticated
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let snapshot = try await db.collection("taskLists")
            .whereField("userId", isEqualTo: userId)
            .whereField("isArchived", isEqualTo: false)
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("createdAt", isLessThan: Timestamp(date: endOfDay))
            .getDocuments()
        
        return try snapshot.documents.map { try TaskList(from: $0) }
    }
    
    func loadTodayLists() async {
        do {
            let lists = try await getTodayLists()
            DispatchQueue.main.async {
                self.currentLists = lists
            }
            
            // Load tasks for each list
            for list in lists {
                try await loadTasksForList(listId: list.id)
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
    
    // MARK: - Task Operations
    
    func loadTasksForList(listId: String) async throws {
        let snapshot = try await db.collection("tasks")
            .whereField("listId", isEqualTo: listId)
            .order(by: "order")
            .getDocuments()
        
        let tasks = try snapshot.documents.map { try Task(from: $0) }
        
        DispatchQueue.main.async {
            self.currentTasks[listId] = tasks
        }
    }
    
    func toggleTaskCompletion(task: Task) async throws {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updatedTask.completedAt = updatedTask.isCompleted ? Date() : nil
        
        // Update task in Firestore
        try await db.collection("tasks").document(task.id).updateData([
            "isCompleted": updatedTask.isCompleted,
            "completedAt": updatedTask.completedAt.map { Timestamp(date: $0) } as Any
        ])
        
        // Update list completion count
        if let list = currentLists.first(where: { $0.id == task.listId }) {
            var updatedList = list
            updatedList.completedCount += updatedTask.isCompleted ? 1 : -1
            updatedList.lastEditedAt = Date()
            
            try await db.collection("taskLists").document(list.id).updateData([
                "completedCount": updatedList.completedCount,
                "lastEditedAt": Timestamp(date: updatedList.lastEditedAt)
            ])
            
            // Update local state
            DispatchQueue.main.async {
                if let index = self.currentTasks[task.listId]?.firstIndex(where: { $0.id == task.id }) {
                    self.currentTasks[task.listId]?[index] = updatedTask
                }
                if let listIndex = self.currentLists.firstIndex(where: { $0.id == list.id }) {
                    self.currentLists[listIndex] = updatedList
                }
            }
        }
    }
    
    func addTask(to listId: String, text: String) async throws {
        guard let list = currentLists.first(where: { $0.id == listId }) else {
            throw TaskError.listNotFound
        }
        
        let currentTaskCount = currentTasks[listId]?.count ?? 0
        
        let task = Task(
            id: UUID().uuidString,
            listId: listId,
            text: text,
            isCompleted: false,
            createdAt: Date(),
            completedAt: nil,
            order: currentTaskCount
        )
        
        // Add task to Firestore
        try await db.collection("tasks").document(task.id).setData(task.firestoreData)
        
        // Update list
        var updatedList = list
        updatedList.taskCount += 1
        updatedList.lastEditedAt = Date()
        
        try await db.collection("taskLists").document(listId).updateData([
            "taskCount": updatedList.taskCount,
            "lastEditedAt": Timestamp(date: updatedList.lastEditedAt)
        ])
        
        // Update local state
        DispatchQueue.main.async {
            self.currentTasks[listId]?.append(task)
            if let index = self.currentLists.firstIndex(where: { $0.id == listId }) {
                self.currentLists[index] = updatedList
            }
        }
    }
    
    // MARK: - Archive Operations
    
    func getArchivedLists() async throws -> [TaskList] {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AuthError.notAuthenticated
        }
        
        let snapshot = try await db.collection("taskLists")
            .whereField("userId", isEqualTo: userId)
            .whereField("isArchived", isEqualTo: true)
            .order(by: "archivedAt", descending: true)
            .getDocuments()
        
        return try snapshot.documents.map { try TaskList(from: $0) }
    }
    
    func loadArchivedLists() async {
        do {
            let lists = try await getArchivedLists()
            DispatchQueue.main.async {
                self.archivedLists = lists
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
            }
        }
    }
    
    func archiveList(_ list: TaskList) async throws {
        var updatedList = list
        updatedList.isArchived = true
        updatedList.archivedAt = Date()
        
        try await db.collection("taskLists").document(list.id).updateData([
            "isArchived": true,
            "archivedAt": Timestamp(date: updatedList.archivedAt!)
        ])
        
        // Update local state
        DispatchQueue.main.async {
            self.currentLists.removeAll(where: { $0.id == list.id })
            self.archivedLists.insert(updatedList, at: 0)
            self.currentTasks.removeValue(forKey: list.id)
        }
    }
    
    func archiveOldLists() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            throw AuthError.notAuthenticated
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        let snapshot = try await db.collection("taskLists")
            .whereField("userId", isEqualTo: userId)
            .whereField("isArchived", isEqualTo: false)
            .whereField("createdAt", isLessThan: Timestamp(date: startOfDay))
            .getDocuments()
        
        let batch = db.batch()
        let now = Date()
        
        for document in snapshot.documents {
            batch.updateData([
                "isArchived": true,
                "archivedAt": Timestamp(date: now)
            ], forDocument: document.reference)
        }
        
        try await batch.commit()
        
        // Refresh both current and archived lists
        await loadTodayLists()
        await loadArchivedLists()
    }
    
    // MARK: - Automatic Archiving
    
    func setupAutomaticArchiving() {
        // Calculate time until next midnight
        let calendar = Calendar.current
        let now = Date()
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
              let nextMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            return
        }
        
        let timeUntilMidnight = nextMidnight.timeIntervalSince(now)
        
        // Schedule the first archive
        Task {
            try await Task.sleep(nanoseconds: UInt64(timeUntilMidnight * 1_000_000_000))
            try await archiveOldLists()
            
            // Schedule subsequent archives every 24 hours
            while true {
                try await Task.sleep(nanoseconds: 24 * 60 * 60 * 1_000_000_000) // 24 hours
                try await archiveOldLists()
            }
        }
    }
}

enum TaskError: LocalizedError {
    case listNotFound
    
    var errorDescription: String? {
        switch self {
        case .listNotFound:
            return "The specified task list could not be found"
        }
    }
} 