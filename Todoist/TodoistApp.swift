//
//  TodoistApp.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/11/21.
//

import SwiftUI

@main
struct TodoistApp: App {
    
    
    @StateObject var authState = AuthState()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {

                Welcome(loginState: $authState.welcomeLoginState, showingAlert: $authState.welcomeAlert, spinner: $authState.welcomeSpinner, buttonTitle: $authState.buttonTitle, buttonVisibility: $authState.buttonVisibility).environmentObject(authState)
            }
            .onOpenURL(perform: { url in
                
                authState.onOpenAction(url: url)

                
            })
            
        }
    }
}
