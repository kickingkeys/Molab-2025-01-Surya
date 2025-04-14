import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    
    private init() {}
    
    func configure() {
        FirebaseApp.configure()
    }
    
    var auth: Auth {
        return Auth.auth()
    }
    
    var firestore: Firestore {
        return Firestore.firestore()
    }
    
    @Published var user: User?
    let db = Firestore.firestore()
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
        }
    }
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String) async throws {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.user = result.user
    }
    
    func signUp(email: String, password: String) async throws {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        self.user = result.user
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
    }
    
    // MARK: - Firestore Operations
    
    func createTaskList(title: String, tasks: [String]) async throws -> String {
        guard let userId = user?.uid else { throw AuthError.notAuthenticated }
        
        let listData: [String: Any] = [
            "userId": userId,
            "title": title,
            "createdAt": Timestamp(),
            "lastEditedAt": Timestamp(),
            "isArchived": false,
            "taskCount": tasks.count,
            "completedCount": 0
        ]
        
        let listRef = try await db.collection("taskLists").addDocument(data: listData)
        
        // Create tasks
        for (index, taskText) in tasks.enumerated() {
            let taskData: [String: Any] = [
                "listId": listRef.documentID,
                "text": taskText,
                "isCompleted": false,
                "createdAt": Timestamp(),
                "order": index
            ]
            try await db.collection("tasks").addDocument(data: taskData)
        }
        
        return listRef.documentID
    }
    
    func getTodayLists() async throws -> [TaskList] {
        guard let userId = user?.uid else { throw AuthError.notAuthenticated }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let snapshot = try await db.collection("taskLists")
            .whereField("userId", isEqualTo: userId)
            .whereField("isArchived", isEqualTo: false)
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("createdAt", isLessThan: Timestamp(date: endOfDay))
            .getDocuments()
        
        return try snapshot.documents.map { try $0.data(as: TaskList.self) }
    }
}

enum AuthError: Error {
    case notAuthenticated
} 