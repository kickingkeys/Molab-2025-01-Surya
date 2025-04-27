//
//  TaskListViewModel.swift
//  Thoughtsort_UI
//
//  Created by Surya Narreddi on 27/04/25.
//

import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    @Published var activeLists: [TaskList] = []
    @Published var archivedLists: [TaskList] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let firestoreManager = FirestoreManager()
    private var cancellables = Set<AnyCancellable>()
    
    func loadActiveLists() {
        isLoading = true
        
        firestoreManager.getTaskLists(archived: false) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let lists):
                DispatchQueue.main.async {
                    self.activeLists = lists
                    self.errorMessage = nil
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loadArchivedLists() {
        isLoading = true
        
        firestoreManager.getTaskLists(archived: true) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let lists):
                DispatchQueue.main.async {
                    self.archivedLists = lists
                    self.errorMessage = nil
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func createTaskList(title: String, taskText: String) {
        isLoading = true
        
        // Parse tasks from text (simple line-by-line parsing)
        let taskLines = taskText.split(separator: "\n")
        let tasks = taskLines.map { taskLine in
            Task(
                title: String(taskLine.trimmingCharacters(in: .whitespacesAndNewlines)),
                isCompleted: false,
                createdAt: Date()
            )
        }
        
        firestoreManager.createTaskList(title: title, tasks: tasks) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(_):
                self.loadActiveLists()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func toggleTaskCompletion(taskListId: String, taskId: String) {
        firestoreManager.toggleTaskCompletion(taskListId: taskListId, taskId: taskId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                // Update local state
                if let listIndex = self.activeLists.firstIndex(where: { $0.id == taskListId }),
                   let taskIndex = self.activeLists[listIndex].tasks.firstIndex(where: { $0.id == taskId }) {
                    DispatchQueue.main.async {
                        self.activeLists[listIndex].tasks[taskIndex].isCompleted.toggle()
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func archiveTaskList(_ taskListId: String) {
        isLoading = true
        
        firestoreManager.archiveTaskList(taskListId) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(_):
                // Update both lists
                self.loadActiveLists()
                self.loadArchivedLists()
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
