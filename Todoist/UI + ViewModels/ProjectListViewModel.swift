//
//  ProjectListViewModel.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/17/21.
//

import Foundation
import KeychainAccess
import Combine
import SwiftUI

class ProjectListViewModel: ObservableObject {
    @Published var projects:[Project] = []

    var taskContent:String? = "?"

    @Published var spinner:Bool = false

    
    private var sessionManager:URLSessionManager?

    init() {
        
        if sessionManager == nil {
            if let token = AuthState.getAccessTokenFromKeychain() {
                sessionManager = URLSessionManager(token: token)

            }
        }
                
    }
    
    

    
    var subscriber: AnyCancellable?
    
    func loadProjects() {
        print("load projects")
        self.spinner = true
        let pub = sessionManager?.projectPublisher()
        subscriber = pub?.sink(receiveCompletion: { (completion) in

            self.spinner = false
            switch completion {
                case .finished:

                    break
                case .failure(let anError):

                    print("received the error: ", anError)
                    break
                }
        }, receiveValue: { (projects) in
            print(".sink() received \(projects)")
            self.projects = projects

        })
        
    }
    
}
