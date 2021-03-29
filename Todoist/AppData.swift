//
//  AppSupport.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/17/21.
//

import Foundation
import KeychainAccess


class AppData:ObservableObject {
    
    //let userRepo = UserRepository()
    
    //static var todoistClientID = "e87862c9e3c64471878820dda9fa5aaa"
    //static var todoistClientSecret = "f604143a35b043d1acc250140549b742"
    //static var todoistSecretState = "secretState"

    static var todoistClientID:String?
    static var todoistClientSecret:String?
    static var todoistSecretState:String?
    
    static var todoistCode:String?
    static var todoistSecretStateReceived:String?
    
    //var todoistToken:String?
    ////static var todoistToken:String?
    //private var sessionManager:URLSessionManager?
    ////@Published var loginStatus = false
    @Published var welcomeLoginState:WelcomeState? = .initialState {
        didSet {
            if welcomeLoginState == .complete {
                spinner = false
            }
        }
    }
    @Published var showingAlert = false {
        didSet {
            if showingAlert == true {
                spinner = false

            }
        }
    }

    @Published var spinner = false

    static let keyChainService = "https://api.todoist.com/rest"
    static let keyChainAccessTokenKey = "accessTokenKey"
    
    
    
    func onOpenAction(url:URL) {
                
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        if let components = components {

            if let queryItems = components.queryItems {
                for queryItem in queryItems {
                    print("\(queryItem.name): \(queryItem.value)")
                    if queryItem.name == "code" {
                        AppData.todoistCode = queryItem.value
                    } else if queryItem.name == "state" {
                        AppData.todoistSecretStateReceived = queryItem.value
                    }
                }
            }
            
            
        }
        
        //        if todoistSecretStateReceived == AppSupport.todoistSecretState {
        if AppData.todoistSecretStateReceived == AppData.todoistSecretState {
            getToken()
        } else {
            welcomeLoginState = .todoistAuthButton
            showingAlert = true
        }
    }
    
    func getToken () {
        spinner = true
        guard let clientID = AppData.todoistClientID else {
            self.welcomeLoginState = .todoistGetTokenButton
            self.showingAlert = true
            return
        }
        
        guard let clientSecret = AppData.todoistClientSecret else {
            self.welcomeLoginState = .todoistGetTokenButton
            self.showingAlert = true
            return
        }
        
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
                                                
                        //self.todoistToken = token
                        //self.userRepo.saveToken(token: token)
                        ////AppSupport.todoistToken = token
                        self.setAccessTokenInKeychain(token: token)
                        //self.sessionManager = URLSessionManager(token: token)
                        ////self.loginStatus = true
                        self.welcomeLoginState = .complete
                        
                    }

                    return
                }
            }
            
            self.welcomeLoginState = .todoistGetTokenButton
            self.showingAlert = true
            
        }
        
        
        
        URLSessionManager.getToken(client_id: clientID, clientSecret: clientSecret, code: AppData.todoistCode, callback: tokenCallback)
    }
    
    
    public static func getAccessTokenFromKeychain() -> String? {
        let keychain = Keychain(service: keyChainService)
        return keychain[keyChainAccessTokenKey]
    }
    
    private func setAccessTokenInKeychain(token:String?) {
        let keychain = Keychain(service: AppData.keyChainService)
        keychain[AppData.keyChainAccessTokenKey] = token


    }

}
