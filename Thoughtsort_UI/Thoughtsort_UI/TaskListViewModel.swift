//
//  TaskListViewModel.swift
//  Thoughtsort_UI
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
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
                
                self.activeLists = documents.map { self.parseTaskList(document: $0) }
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
                
                self.archivedLists = documents.map { self.parseTaskList(document: $0) }
            }
    }
    
    // Create a new Task List (⚡ fixed)
    func createTaskList(title: String) {
        let userId = Auth.auth().currentUser?.uid ?? "unknown_user"
        var newTaskList = TaskList(title: title, userId: userId)
        
        do {
            let taskListRef = db.collection("taskLists").document(newTaskList.id)
            try taskListRef.setData(from: newTaskList)
            print("✅ Successfully created task list with ID: \(newTaskList.id)")
        } catch {
            print("Error creating task list: \(error.localizedDescription)")
        }
    }
    
    // Add a task to a list
    func addTask(to taskListId: String, taskTitle: String) {
        guard let index = activeLists.firstIndex(where: { $0.id == taskListId }) else { return }
        
        let newTask = Task(
            title: taskTitle,
            isCompleted: false,
            createdAt: Date()
        )
        
        activeLists[index].tasks.append(newTask)
        
        let updatedTasks = activeLists[index].tasks.map { [
            "id": $0.id,
            "title": $0.title,
            "isCompleted": $0.isCompleted,
            "createdAt": Timestamp(date: $0.createdAt)
        ]}
        
        db.collection("taskLists").document(taskListId).updateData([
            "tasks": updatedTasks
        ])
    }
    
    // Toggle completion
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
        let ref = db.collection("taskLists").document(listId)
        
        ref.updateData(["isArchived": true]) { error in
            if let error = error {
                print("Error archiving task list: \(error.localizedDescription)")
            } else {
                print("✅ Successfully archived task list.")
                self.loadActiveLists()
            }
        }
    }
    
    // Delete a task list
    func deleteTaskList(listId: String) {
        db.collection("taskLists").document(listId).delete { error in
            if let error = error {
                print("Error deleting task list: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.loadActiveLists()
                }
            }
        }
    }
    
    // Delete a specific task
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
    
    // Helper to parse Firestore document
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
