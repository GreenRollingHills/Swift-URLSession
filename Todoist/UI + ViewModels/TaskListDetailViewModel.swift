//
//  TaskListDetailViewModel.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/14/21.
//

import Foundation
import SwiftUI
import Combine

class TaskListDetailViewModel: ObservableObject {
    
    weak var taskListVM:TaskListViewModel?
    
    @Published var task:Task? = nil
    
    private var sessionManager:URLSessionManager?

    init() {

        print("taskListDetail VM init")
        
        if sessionManager == nil {
            if let token = AuthState.getAccessTokenFromKeychain() {
                sessionManager = URLSessionManager(token: token)
            }
        }
        
    }
    
    func setUp(task:Task, taskListVM:TaskListViewModel) {
        self.task = task
        self.taskListVM = taskListVM
    }
    
    var deleteState = false {
        didSet {
            if deleteState == true {
                if let task = task {
                    deleteTask(task: task)
                }
            }
        }
    }
    
    var completeState = false {
        didSet {
            if completeState == true {
                if let task = task {
                    completeTask(task: task)

                }
            }
        }
    }
    
    var completeTaskSub:AnyCancellable?
    var deleteTaskSub:AnyCancellable?
    
    func completeTask(task:Task) {
        if let task = self.task {
            taskListVM?.spinner = true
            let pub = sessionManager?.closeTaskPublisher(taskID: task.id)
            completeTaskSub = pub?.sink(receiveCompletion: { (completion) in
                self.taskListVM?.loadTasks()
            }, receiveValue: { (value) in
                
            })

        }
        
    }
    
    func deleteTask(task:Task)  {
        taskListVM?.spinner = true
        let pub = sessionManager?.deleteTaskPublisher(taskID: task.id)
        deleteTaskSub = pub?.sink(receiveCompletion: { (completion) in
            print("delete task complete : \(completion)")
            self.taskListVM?.loadTasks()
        }, receiveValue: { (value) in
            print("delete task value : \(value)")
        })

    }
    
    
}
