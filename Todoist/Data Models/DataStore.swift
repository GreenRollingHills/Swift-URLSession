//
//  Data.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/12/21.
//

import Foundation
import Combine

// 1
class DataStore: ObservableObject {
    @Published var studyList:[String]
    @Published var projects:[Project]?
    @Published var tasks:[Task]?
    @Published var loginStatus = false
    var taskContent:String?
    
    let todoistClientID = "e87862c9e3c64471878820dda9fa5aaa"
    let todoistClientSecret = "f604143a35b043d1acc250140549b742"
    
    var todoistCode:String?
    let todoistSecretState = "secretState"
    var todoistSecretStateReceived:String?
    
    var todoistToken:String?

    //let sessionManager = URLSessionManager()
    var sessionManager:URLSessionManager?
    
    init() {
        self.studyList = ["Math", "American History",
                     "Roman History", "Socical Studies",
                     "American Literature", "Biology",
                     "Spanish", "Chess"]

    }
    
    func loadProjects () {
        
        let projectCallback:DataTaskClosure = {
            data, response, error in
            print("DataStore, loadProjects callback")
            print("data : \(data)")
            print("response : \(response)")
            print("error : \(error)")
            if let data = data {
                print("data : \(data)")
                
                if let decodedResponse = try? JSONDecoder().decode([Project].self, from: data) {
                    print("recodedResponse : \(decodedResponse)")
                    DispatchQueue.main.async {
                        self.projects = decodedResponse
                        self.loginStatus = true
                    }

                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }
        sessionManager?.loadProjects(callback: projectCallback)
        
    }
    
    func loadTasks (projectID:Int?) {
        print("loadTasks for \(projectID)")
        let taskCallback:DataTaskClosure = {
            data, response, error in
            print("load task callback")
            print("data : \(data)")
            print("response : \(response)")
            print("error : \(error)")
            
            if let data = data {
                print("data : \(data)")

                if let decodedResponse = try? JSONDecoder().decode([Task].self, from: data) {

                    print("recodedResponse : \(decodedResponse)")
                    DispatchQueue.main.async {

                        self.tasks = decodedResponse
                        
                    }

                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }
        
        sessionManager?.loadTasks(projectID: projectID, callback: taskCallback)
    }
    
    func createTask(projectID:Int?, content:String?) {
        let createCallback:DataTaskClosure = {
            data, response, error in
            print("create task")
            print("data : \(data)")
            print("response : \(response)")
            print("error : \(error)")
            
            if let data = data {
                print("data : \(data)")

                if let decodedResponse = try? JSONDecoder().decode(Task.self, from: data) {

                    print("recodedResponse : \(decodedResponse)")
                    DispatchQueue.main.async {

                        self.tasks?.append(decodedResponse)
                        
                    }

                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }
        
        sessionManager?.createTask(projectID:projectID, content: content, callback:createCallback)
    }
    
    func getToken () {
        
        let tokenCallback:DataTaskClosure = {
            data, reponse, error in
            
            if let data = data {
                print("data : \(data)")

                if let decodedResponse = try? JSONDecoder().decode(AuthData.self, from: data) {

                    print("recodedResponse : \(decodedResponse)")
                    DispatchQueue.main.async {
                        guard let token = decodedResponse.access_token else {
                            return
                        }
                        self.todoistToken = token
                        self.sessionManager = URLSessionManager(token: token)
                        self.loginStatus = true
                        
                    }

                    return
                }
            }
            
        }
        
        URLSessionManager.getToken(client_id: todoistClientID, clientSecret: todoistClientSecret, code: todoistCode, callback: tokenCallback)
    }

}
