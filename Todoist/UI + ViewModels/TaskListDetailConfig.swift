//
//  TaskListConfig.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/28/21.
//

import Foundation
import SwiftUI

struct TaskListDetailConfig {
    var task:Task

    
    private var sessionManager:URLSessionManager?

    @State var deleteState = false {
        didSet {
            if deleteState == true {
                deleteTask(task: task)
            }
        }
    }
    
    @State var completeState = false {
        didSet {
            if completeState == true {
                completeTask(task: task)
            }
        }
    }
    
    @Binding var taskListSpinner:Bool
    @Binding var taskLoad:Bool
    
    
    init(task:Task, taskListSpinner:Binding<Bool>, taskLoad:Binding<Bool>) {
        print("taskListDetail config init")
        
        self.task = task
        
        _taskListSpinner = taskListSpinner
        _taskLoad = taskLoad
        
        if sessionManager == nil {
            if let token = AuthState.getAccessTokenFromKeychain() {
                sessionManager = URLSessionManager(token: token)
            }
        }
        
    }
    
    
    func completeTask(task:Task) {
        taskListSpinner = true
        sessionManager?.closeTask(taskID: task.id, callback: {
            data, response, error in
            
            DispatchQueue.main.async {
                self.taskLoad = true

            }
             
        })
        
    }
    
    func deleteTask(task:Task)  {
        taskListSpinner = true
        sessionManager?.deleteTask(taskID: task.id, callback: {
            data, response, error in
            print("deleteTask callback")
            print("data : \(data)")
            print("response : \(response)")
            print("error : \(error)")
            
            DispatchQueue.main.async {
                self.taskLoad = true

            }
            
            //self.loadTasks()
        })
    }
    
}
