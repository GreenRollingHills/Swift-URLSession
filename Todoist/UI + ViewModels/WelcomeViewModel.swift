//
//  WelcomeViewModel.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/20/21.
//

import Foundation
import SwiftUI
import KeychainAccess

enum WelcomeState:Int {
    case initialState
    case complete
    case getConstantsActive
    case todoistLoginActive
    case getConstantsButton
    case getTokenActive
    case todoistAuthButton
    case todoistGetTokenButton
    
    
}

public class WelcomeViewModel: ObservableObject {
    @Binding var loginStatus:WelcomeState? {
        didSet {
            print("welcome, loginStatus : \(loginStatus)")

        }
    }
    
    
    @Binding var buttonTitle:String?
    @Binding var buttonVisibility:Bool?
        
    @Binding var showingAlert:Bool {
        didSet {

        }
    }
    
    @Binding var spinner:Bool

    
    init(loginState: Binding<WelcomeState?>, showingAlert:Binding<Bool>, spinner:Binding<Bool>,
         buttonTitle:Binding<String?>,
         buttonVisibility:Binding<Bool?>) {
        _loginStatus = loginState
        _showingAlert = showingAlert
        _spinner = spinner
        _buttonTitle = buttonTitle
        _buttonVisibility = buttonVisibility
    }
    
    func accessTokenAction() {
        print("accessTokenAction")
        if loginStatus != .complete {
            if AuthState.getAccessTokenFromKeychain() != nil {
                print("about to change loginStatus to .complete")
                loginStatus = .complete
            } else {
                loginStatus = .getConstantsActive
            }
        }
                
    }

    
}
