import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class TaskListViewModel: ObservableObject {
    @Published var activeLists: [TaskList] = []
    @Published var archivedLists: [TaskList] = []
    @Published var claudeErrorMessage: String? = nil

    private var db = Firestore.firestore()
    private var hasArchivedToday = false  // ✅ Run archive only once per day

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

    func generateTaskListFromInput(input: String, title: String, idOverride: String? = nil, completion: @escaping (TaskList?) -> Void) {
        let userId = Auth.auth().currentUser?.uid ?? "unknown_user"
        let newListId = idOverride ?? UUID().uuidString
        var newTaskList = TaskList(id: newListId, title: title, userId: userId)

        // ✅ Insert placeholder immediately
        activeLists.insert(newTaskList, at: 0)
        let docRef = db.collection("taskLists").document(newTaskList.id)

        do {
            try docRef.setData(from: newTaskList)
        } catch {
            print("🔥 Failed to create list placeholder: \(error.localizedDescription)")
            completion(nil)
            return
        }

        ClaudeAPI.generateTasks(from: input) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let taskTitles):
                    let newTasks = taskTitles.map { Task(title: $0) }
                    newTaskList.tasks = newTasks
                    do {
                        try docRef.setData(from: newTaskList)
                        self.loadActiveLists()
                        completion(newTaskList)
                    } catch {
                        print("🔥 Failed to save list with tasks: \(error.localizedDescription)")
                        completion(nil)
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
                    completion(nil)
                }
            }
        }
    }

    func addNewList(_ taskList: TaskList) {
        let docRef = db.collection("taskLists").document(taskList.id)
        do {
            try docRef.setData(from: taskList)
            self.activeLists.insert(taskList, at: 0)
        } catch {
            print("🔥 Failed to save task list: \(error.localizedDescription)")
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

    func archiveOldLists() {
        guard !hasArchivedToday else {
            print("🟡 Skipping archive: already ran today.")
            return
        }

        print("📆 Running archiveOldLists()...")

        let calendar = Calendar(identifier: .gregorian)
        let currentDayStart = calendar.startOfDay(for: Date())
        print("🔸 Current local day start: \(currentDayStart)")

        for list in activeLists {
            let listDayStart = calendar.startOfDay(for: list.createdAt)
            print("""
            📝 Checking list: \(list.title)
            └ createdAt: \(list.createdAt)
            └ dayStart:  \(listDayStart)
            """)

            if listDayStart < currentDayStart {
                print("⏳ Archiving list: \(list.title) — created before today.")
                archiveTaskList(list.id)
            } else {
                print("✅ Keeping list: \(list.title) — created today.")
            }
        }

        hasArchivedToday = true
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
