//
//  URLSession.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/14/21.
//

import Foundation
import Combine
import SwiftUI

typealias DataTaskClosure = (Data?,URLResponse?, Error?)-> Void


class URLSessionManager:NSObject {
    var session:URLSession?
            
    init(token:String) {
        print("URLSessionManager init")
        super.init()
        let sessionConfig = URLSessionConfiguration.default
        let authValue: String = "Bearer \(token)"
        sessionConfig.httpAdditionalHeaders = ["Authorization": authValue]
        
        session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }
    
    func tasksPublisher(projectID:Int?) -> AnyPublisher<[Task], Never>? {
        guard let projectIDTemp = projectID else {
            return nil
        }
        
        guard var components = URLComponents(string: "https://api.todoist.com/rest/v1/tasks") else {
            print("Invalid URL")
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "project_id", value: String(projectIDTemp))
        ]
        
        guard let url = components.url else {
            return nil
        }
        
        let publisher = session?.dataTaskPublisher(for: url)
            .retry(1)
            .tryMap() { element -> Data in
                print("response : \(element.response)")
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                            throw URLError(.badServerResponse)
                        }
                        return element.data
                    }
            
            .decode(type: [Task].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .catch({ (error) -> Just<[Task]> in
                let urlError = error as? URLError
                print("urlError : \(urlError)")

                
                return Just([])

            })
            .eraseToAnyPublisher()

    
        return publisher
        
        
    }
    

    
    func projectPublisher() -> AnyPublisher<[Project], Never>? {
        print("projectPublisher")
                
        let url = URL(string: "https://api.todoist.com/rest/v1/projects")!
        
        let publisher = session?.dataTaskPublisher(for: url)
            .retry(1)
            .tryMap() { element -> Data in
                print("response : \(element.response)")
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                            throw URLError(.badServerResponse)
                        }
                        return element.data
                    }
            
            .decode(type: [Project].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .catch({ (error) -> Just<[Project]> in
                let urlError = error as? URLError
                print("urlError : \(urlError)")

                
                return Just([])

            })
            .eraseToAnyPublisher()

    
        return publisher
    }
    
    
    
    func closeTaskPublisher(taskID:Int?) -> AnyPublisher<Void, Never>? {
        guard let taskIDFinal = taskID else {
            return nil
        }
        guard let url = URL(string: "https://api.todoist.com/rest/v1/tasks/\(taskIDFinal)/close") else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let basePub = session?.dataTaskPublisher(for: request)
        let pub = basePub?.emptyBodyResponsePublisher(validResponseCode: 204)
        return pub

    }
    
    
    func deleteTaskPublisher (taskID:Int?) -> AnyPublisher<Void, Never>? {
        print("session, deleteTask")

        guard let taskIDFinal = taskID else {
            return nil
        }
        print("deleteTask, taskIDFinal : \(taskIDFinal)")
        guard let url = URL(string: "https://api.todoist.com/rest/v1/tasks/\(taskIDFinal)") else {
            print("Invalid URL")
            return nil
        }
        
        print("url : \(url)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let basePub = session?.dataTaskPublisher(for: request)
        let pub = basePub?.emptyBodyResponsePublisher(validResponseCode: 204)
        return pub
        
        
    }
    
    func createTaskPublisher (projectID:Int?, content:String?) -> AnyPublisher<Task, Error>? {
        print("session, createTask")

        guard let url = URL(string: "https://api.todoist.com/rest/v1/tasks") else {
            print("Invalid URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var task = Task()
        let topic = content ?? "everything !"
        task.content = "Need to study \(topic)"
        task.project_id = projectID
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(task)
            request.httpBody = data
            
            let publisher = session?.dataTaskPublisher(for: request)

                .retry(1)
                .tryMap() { element -> Data in
                    print("response : \(element.response)")
                        guard let httpResponse = element.response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                                throw URLError(.badServerResponse)
                            }
                            return element.data
                        }
                
                .decode(type: Task.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()

        
            return publisher
        } catch {
            
        }
        
        return nil
        
    }
    
    
    static func getTokenPublisher (client_id:String, clientSecret:String, code:String?) -> AnyPublisher<TodoistAuthData, Error>? {
        
        print("sessionManager, getToken")
        
        let tokenSession = URLSession(configuration: .default)

        guard var components = URLComponents(string: "https://todoist.com/oauth/access_token") else {
            print("Invalid URL")
            return nil
        }

        components.queryItems = [
            URLQueryItem(name: "client_id", value: client_id),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "code", value: code)

        ]
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let publisher = tokenSession.dataTaskPublisher(for: request)
            .retry(1)
            .tryMap() { element -> Data in
                print("response : \(element.response)")
                    guard let httpResponse = element.response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                            throw URLError(.badServerResponse)
                        }
                        return element.data
                    }
            
            .decode(type: TodoistAuthData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

    
        return publisher
        
    }
    
    deinit {
        session?.invalidateAndCancel()
    }
    
}


extension URLSession.DataTaskPublisher {
    func emptyBodyResponsePublisher(validResponseCode:Int) -> AnyPublisher<Void, Never> {
        tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == validResponseCode else {
                        throw URLError(.badServerResponse)
                    }
                    return Void()
                }
        .replaceError(with: Void())
        .eraseToAnyPublisher()
    }
}

extension URLSessionManager : URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        for metric in metrics.transactionMetrics {
            print(metric)
        }
    }
}
