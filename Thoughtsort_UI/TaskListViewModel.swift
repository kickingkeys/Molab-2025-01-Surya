import Foundation
import FirebaseFirestore

class TaskListViewModel: ObservableObject {
    @Published var activeLists: [TaskList] = []
    @Published var archivedLists: [TaskList] = []
    
    private var db = Firestore.firestore()

    init() {
        loadActiveLists()
        listenToArchivedLists()
    }
    
    // Load Active Lists
    func loadActiveLists() {
        db.collection("taskLists")
            .whereField("isArchived", isEqualTo: false)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading active lists: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                self.activeLists = documents.map { doc -> TaskList in
                    self.parseTaskList(document: doc)
                }
            }
    }
    
    // Load Archived Lists
    func listenToArchivedLists() {
        db.collection("taskLists")
            .whereField("isArchived", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error loading archived lists: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                self.archivedLists = documents.map { doc -> TaskList in
                    self.parseTaskList(document: doc)
                }
            }
    }
    
    // Create a new Task List
    func createTaskList(title: String) {
        let newList: [String: Any] = [
            "id": UUID().uuidString,
            "title": title,
            "tasks": [],
            "createdAt": Timestamp(date: Date()),
            "isArchived": false,
            "userId": ""
        ]
        
        db.collection("taskLists").addDocument(data: newList) { error in
            if let error = error {
                print("Error creating task list: \(error.localizedDescription)")
            }
        }
    }
    
    // Add a task to an existing list
    func addTask(to taskListId: String, taskTitle: String) {
        guard let index = activeLists.firstIndex(where: { $0.id == taskListId }) else { return }
        
        let newTask = Task(
            title: taskTitle,
            isCompleted: false,
            createdAt: Date()
        )
        
        activeLists[index].tasks.append(newTask)
        
        let taskData = activeLists[index].tasks.map { [
            "id": $0.id,
            "title": $0.title,
            "isCompleted": $0.isCompleted,
            "createdAt": Timestamp(date: $0.createdAt)
        ]}
        
        db.collection("taskLists").document(taskListId).updateData([
            "tasks": taskData
        ])
    }
    
    // Toggle task completion
    func toggleTaskCompletion(taskListId: String, taskId: String) {
        guard let listIndex = activeLists.firstIndex(where: { $0.id == taskListId }) else { return }
        guard let taskIndex = activeLists[listIndex].tasks.firstIndex(where: { $0.id == taskId }) else { return }
        
        activeLists[listIndex].tasks[taskIndex].isCompleted.toggle()
        
        let updatedTasks = activeLists[listIndex].tasks.map { [
            "id": $0.id,
            "title": $0.title,
            "isCompleted": $0.isCompleted,
            "createdAt": Timestamp(date: $0.createdAt)
        ]}
        
        db.collection("taskLists").document(taskListId).updateData([
            "tasks": updatedTasks
        ])
    }
    
    // Archive a task list
    func archiveTaskList(_ listId: String) {
        db.collection("taskLists").document(listId).updateData([
            "isArchived": true
        ]) { error in
            if let error = error {
                print("Error archiving task list: \(error.localizedDescription)")
            } else {
                self.loadActiveLists()
            }
        }
    }
    
    // Delete a full task list
    func deleteTaskList(listId: String) {
        db.collection("taskLists").document(listId).delete { error in
            if let error = error {
                print("Error deleting task list: \(error.localizedDescription)")
            } else {
                self.loadActiveLists()
            }
        }
    }
    
    // 🆕 Delete a specific task inside a list
    func deleteTask(taskListId: String, taskId: String) {
        guard let listIndex = activeLists.firstIndex(where: { $0.id == taskListId }) else { return }
        guard let taskIndex = activeLists[listIndex].tasks.firstIndex(where: { $0.id == taskId }) else { return }
        
        activeLists[listIndex].tasks.remove(at: taskIndex)
        
        let updatedTasks = activeLists[listIndex].tasks.map { [
            "id": $0.id,
            "title": $0.title,
            "isCompleted": $0.isCompleted,
            "createdAt": Timestamp(date: $0.createdAt)
        ]}
        
        db.collection("taskLists").document(taskListId).updateData([
            "tasks": updatedTasks
        ]) { error in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            }
        }
    }
    
    // Helper - manually parse Firestore document into TaskList
    private func parseTaskList(document: QueryDocumentSnapshot) -> TaskList {
        let data = document.data()
        
        let id = data["id"] as? String ?? document.documentID
        let title = data["title"] as? String ?? ""
        let isArchived = data["isArchived"] as? Bool ?? false
        let createdAtTimestamp = data["createdAt"] as? Timestamp ?? Timestamp()
        let createdAt = createdAtTimestamp.dateValue()
        let userId = data["userId"] as? String ?? ""
        
        var tasks: [Task] = []
        if let taskDataArray = data["tasks"] as? [[String: Any]] {
            tasks = taskDataArray.map { taskData in
                Task(
                    id: taskData["id"] as? String ?? UUID().uuidString,
                    title: taskData["title"] as? String ?? "",
                    isCompleted: taskData["isCompleted"] as? Bool ?? false,
                    createdAt: (taskData["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                )
            }
        }
        
        return TaskList(
            id: id,
            title: title,
            tasks: tasks,
            createdAt: createdAt,
            isArchived: isArchived,
            userId: userId
        )
    }
}
