import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class TaskListViewModel: ObservableObject {
    @Published var activeLists: [TaskList] = []
    @Published var archivedLists: [TaskList] = []
    @Published var claudeErrorMessage: String? = nil

    private var db = Firestore.firestore()

    init() {
        loadActiveLists()
        listenToArchivedLists()
    }

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

    func generateTaskListFromInput(input: String, title: String, idOverride: String? = nil) {
        let userId = Auth.auth().currentUser?.uid ?? "unknown_user"
        let newListId = idOverride ?? UUID().uuidString
        var newTaskList = TaskList(id: newListId, title: title, userId: userId)

        let docRef = db.collection("taskLists").document(newTaskList.id)
        do {
            try docRef.setData(from: newTaskList)
        } catch {
            print("🔥 Failed to create new list: \(error.localizedDescription)")
            return
        }

        self.activeLists.insert(newTaskList, at: 0)

        ClaudeAPI.generateTasks(from: input) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let taskTitles):
                    let newTasks = taskTitles.map { Task(title: $0) }
                    newTaskList.tasks = newTasks

                    do {
                        try docRef.setData(from: newTaskList)
                        self.loadActiveLists()
                    } catch {
                        print("🔥 Failed to update list with tasks: \(error.localizedDescription)")
                    }

                case .failure(let error):
                    self.claudeErrorMessage = {
                        switch error {
                        case .invalidAPIKey:
                            return "Your Claude API key is missing or invalid."
                        case .networkError(let err):
                            return "Network error: \(err.localizedDescription)"
                        case .apiError(let msg):
                            return "Claude API error: \(msg)"
                        case .parsingError(let msg):
                            return "Couldn’t understand Claude’s response. \(msg)"
                        }
                    }()
                }
            }
        }
    }

    func addTask(to taskListId: String, taskTitle: String) {
        guard let index = activeLists.firstIndex(where: { $0.id == taskListId }) else { return }

        let newTask = Task(
            title: taskTitle,
            isCompleted: false,
            createdAt: Date()
        )

        activeLists[index].tasks.append(newTask)

        let updatedTasks = activeLists[index].tasks.map {
            [
                "id": $0.id,
                "title": $0.title,
                "isCompleted": $0.isCompleted,
                "createdAt": Timestamp(date: $0.createdAt)
            ]
        }

        db.collection("taskLists").document(taskListId).updateData([
            "tasks": updatedTasks
        ])
    }

    func toggleTaskCompletion(taskListId: String, taskId: String) {
        guard let listIndex = activeLists.firstIndex(where: { $0.id == taskListId }) else { return }
        guard let taskIndex = activeLists[listIndex].tasks.firstIndex(where: { $0.id == taskId }) else { return }

        activeLists[listIndex].tasks[taskIndex].isCompleted.toggle()

        let updatedTasks = activeLists[listIndex].tasks.map {
            [
                "id": $0.id,
                "title": $0.title,
                "isCompleted": $0.isCompleted,
                "createdAt": Timestamp(date: $0.createdAt)
            ]
        }

        db.collection("taskLists").document(taskListId).updateData([
            "tasks": updatedTasks
        ])
    }

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

    func deleteTask(taskListId: String, taskId: String) {
        guard let listIndex = activeLists.firstIndex(where: { $0.id == taskListId }) else { return }
        guard let taskIndex = activeLists[listIndex].tasks.firstIndex(where: { $0.id == taskId }) else { return }

        activeLists[listIndex].tasks.remove(at: taskIndex)

        let updatedTasks = activeLists[listIndex].tasks.map {
            [
                "id": $0.id,
                "title": $0.title,
                "isCompleted": $0.isCompleted,
                "createdAt": Timestamp(date: $0.createdAt)
            ]
        }

        db.collection("taskLists").document(taskListId).updateData([
            "tasks": updatedTasks
        ]) { error in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            }
        }
    }

    /// ✅ NEW: Archive all lists not created today
    func archiveOldLists() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for list in activeLists {
            let createdDay = calendar.startOfDay(for: list.createdAt)
            if createdDay < today {
                archiveTaskList(list.id)
            }
        }
    }

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
