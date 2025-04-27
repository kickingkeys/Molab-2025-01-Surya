//
//  FirestoreManager.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 27/04/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager: ObservableObject {
    private let db = Firestore.firestore()
    
    // MARK: - Task Lists
    
    func createTaskList(title: String, tasks: [Task], completion: @escaping (Result<TaskList, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirestoreManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let newList = TaskList(
            title: title,
            tasks: tasks,
            createdAt: Date(),
            userId: userId
        )
        
        do {
            try db.collection("taskLists").document(newList.id).setData(from: newList)
            completion(.success(newList))
        } catch {
            completion(.failure(error))
        }
    }
    
    func getTaskLists(archived: Bool, completion: @escaping (Result<[TaskList], Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "FirestoreManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("taskLists")
            .whereField("userId", isEqualTo: userId)
            .whereField("isArchived", isEqualTo: archived)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let taskLists = documents.compactMap { document -> TaskList? in
                    try? document.data(as: TaskList.self)
                }
                
                completion(.success(taskLists))
            }
    }
    
    func updateTaskList(_ taskList: TaskList, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try db.collection("taskLists").document(taskList.id).setData(from: taskList)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
    
    func archiveTaskList(_ taskListId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = db.collection("taskLists").document(taskListId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(ref)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var taskList = try? document.data(as: TaskList.self) else {
                let error = NSError(
                    domain: "FirestoreManager",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Document doesn't exist or couldn't be parsed."]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            taskList.isArchived = true
            
            do {
                try transaction.setData(from: taskList, forDocument: ref)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
            
            return nil
        }) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteTaskList(_ taskListId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("taskLists").document(taskListId).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Individual Task Management
    
    func toggleTaskCompletion(taskListId: String, taskId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = db.collection("taskLists").document(taskListId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(ref)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard var taskList = try? document.data(as: TaskList.self) else {
                let error = NSError(
                    domain: "FirestoreManager",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Document doesn't exist or couldn't be parsed."]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            if let index = taskList.tasks.firstIndex(where: { $0.id == taskId }) {
                taskList.tasks[index].isCompleted.toggle()
                
                do {
                    try transaction.setData(from: taskList, forDocument: ref)
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }
            
            return nil
        }) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
