//
//  AuthState.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/24/21.
//

import Foundation
import KeychainAccess
import SwiftUI
import Combine



class AuthState:ObservableObject {
    
    static var todoistClientID:String?
    static var todoistClientSecret:String?
    static var todoistSecretState:String?
    
    static var todoistCode:String?
    static var todoistSecretStateReceived:String?
    
    static let keyChainService = "https://api.todoist.com/rest"
    static let keyChainAccessTokenKey = "accessTokenKey"
    
    @Published var welcomeLoginState:WelcomeState? = .initialState {
        didSet {
            print("authState, loginStatus : \(welcomeLoginState)")
            if welcomeLoginState == .complete {
                welcomeSpinner = false
            } else if welcomeLoginState == .getConstantsActive {
                getiCloudConstants()
            }
            
            switch welcomeLoginState {
            case .getConstantsButton:
                buttonTitle = "iCloud Login"
            case .todoistAuthButton, .todoistGetTokenButton:
                buttonTitle = "Todoist Login"
            default:
                buttonTitle = ""
            }
            
            switch welcomeLoginState {
            case .getConstantsButton, .todoistAuthButton, .todoistGetTokenButton:
                buttonVisibility = true
            default:
                buttonVisibility = false
            }
            
            if welcomeLoginState == .todoistLoginActive {
                sendToTodoistAuthPage()
            }
            
        }
    }
    @Published var welcomeAlert = false {
        didSet {
            if welcomeAlert == true {
                welcomeSpinner = false

            }
        }
    }

    @Published var buttonTitle:String?
    @Published var buttonVisibility:Bool?
    
    @Published var welcomeSpinner = false

    func onOpenAction(url:URL) {
                
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        if let components = components {

            if let queryItems = components.queryItems {
                for queryItem in queryItems {
                    print("\(queryItem.name): \(queryItem.value)")
                    if queryItem.name == "code" {
                        AuthState.todoistCode = queryItem.value
                    } else if queryItem.name == "state" {
                        AuthState.todoistSecretStateReceived = queryItem.value

                    }
                }
            }
            
            
        }
        

        if AuthState.todoistSecretStateReceived == AuthState.todoistSecretState {
            getToken()
        } else {
            welcomeLoginState = .todoistAuthButton
            welcomeAlert = true
        }
    }
    
    var getTokenSub:AnyCancellable?
    
    func getToken () {
        
        welcomeSpinner = true
        guard let clientID = AuthState.todoistClientID else {
            self.welcomeLoginState = .todoistGetTokenButton
            self.welcomeAlert = true
            return
        }
        
        guard let clientSecret = AuthState.todoistClientSecret else {
            self.welcomeLoginState = .todoistGetTokenButton
            self.welcomeAlert = true
            return
        }
        
        let pub = URLSessionManager.getTokenPublisher(client_id: clientID, clientSecret: clientSecret, code: AuthState.todoistCode)
        getTokenSub = pub?.sink(receiveCompletion: {(completion) in
            
            switch completion {
                case .finished:

                    self.welcomeLoginState = .complete
                    break
                case .failure(let anError):

                    print("received the error: ", anError)
                    self.welcomeLoginState = .todoistGetTokenButton
                    self.welcomeAlert = true
                    break
                }
            
        }, receiveValue: {(authData) in
            if let token = authData.access_token {
                self.setAccessTokenInKeychain(token: token)

            }
        })

        
    }
    
    func sendToTodoistAuthPage() {
        if let url = self.authLink() {
            AuthState.todoistCode = nil
            AuthState.todoistSecretStateReceived = nil
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    func authLink() -> URL? {
        if let todoistClientID = AuthState.todoistClientID {
            if let todoistSecretState = AuthState.todoistSecretState {
                return URL(string: "https://todoist.com/oauth/authorize?client_id=\(todoistClientID)&scope=data:read_write,data:delete&state=\(todoistSecretState)")

            }
        }
        
        return nil

    }
    
    func getiCloudConstants () {
        self.welcomeSpinner = true
        CloudAuthData.fetchNotes { (result) in
            print("cloud result : \(result)")
            self.welcomeSpinner = false
            do {
                if let data = try result.get().first {
                    print("clientID : \(data.clientID ?? "?")")
                    print("clientSecret : \(data.clientSecret ?? "?")")
                    if let clientID = data.clientID {
                        AuthState.todoistClientID = clientID
                    }
                    if let clientSecret = data.clientSecret {
                        AuthState.todoistClientSecret = clientSecret

                    }
                    if let clientSecretState = data.clientSecretState {
                        AuthState.todoistSecretState = clientSecretState

                    }
                    
                    self.welcomeLoginState = .todoistLoginActive
                }
                
            } catch {
                self.welcomeLoginState = .getConstantsButton
                self.welcomeAlert = true
            }
        }
    }
    
    public static func getAccessTokenFromKeychain() -> String? {
        let keychain = Keychain(service: keyChainService)
        return keychain[keyChainAccessTokenKey]
    }
    
    private func setAccessTokenInKeychain(token:String?) {
        let keychain = Keychain(service: AuthState.keyChainService)
        keychain[AuthState.keyChainAccessTokenKey] = token


    }
}
