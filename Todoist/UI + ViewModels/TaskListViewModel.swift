//
//  TaskListViewModel.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/17/21.
//

import Foundation
import SwiftUI
import Combine


class TaskListViewModel: ObservableObject {
        
    private var sessionManager:URLSessionManager?
    var projectID:Int? = nil

    @Published var tasks:[Task] = []

    var taskContent:String? = nil

    @Published var spinner:Bool = false
    
    func setUp(projectID:Int?, taskContent:String) {
        self.projectID = projectID
        self.taskContent = taskContent
        
    }
    

    init() {

        
        if sessionManager == nil {
            if let token = AuthState.getAccessTokenFromKeychain() {
                sessionManager = URLSessionManager(token: token)
            }
        }
        
    }
    
    
    var loadTaskSub:AnyCancellable?
    
    func loadTasks () {
        print("loadTasks for \(projectID)")
        
        spinner = true
        let pub = sessionManager?.tasksPublisher(projectID: projectID)
        loadTaskSub = pub?.sink(receiveCompletion: { (completion) in
            print("loadTasks completion : \(completion)")
            self.spinner = false
        }, receiveValue: { (tasks) in
            //print("loadTasks value : \(tasks)")
            tasks.forEach({
                print("\($0)")
            })
            self.tasks = tasks
        })
    }
    
    var createTaskSub:AnyCancellable?
    
    func createTask() {
        
        spinner = true
        
        let pub = sessionManager?.createTaskPublisher(projectID: projectID, content: taskContent)
        createTaskSub = pub?.sink(receiveCompletion: { (completion) in
            print("taskVM, completion : \(completion)")
            self.spinner = false
        }, receiveValue: { (task) in
            print("taksVM, receiveValue : \(task)")
            self.tasks.append(task)
        })
        

    }
}


