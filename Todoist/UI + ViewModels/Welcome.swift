//
//  ContentView.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/11/21.
//

import Foundation
import SwiftUI
import CloudKit

struct Welcome: View {

    @Environment(\.openURL) var openURL

    @EnvironmentObject var authState:AuthState
    @ObservedObject var vm:WelcomeViewModel

    init(loginState:Binding<WelcomeState?>, showingAlert:Binding<Bool>, spinner:Binding<Bool>,
         buttonTitle:Binding<String?>, buttonVisibility:Binding<Bool?>) {
        vm = WelcomeViewModel(loginState: loginState, showingAlert: showingAlert, spinner: spinner, buttonTitle: buttonTitle, buttonVisibility: buttonVisibility)


    }


    var body: some View {
        
        ZStack {
         
            VStack {
                
                NavigationLink(destination: ItemList(), tag: .complete, selection: $vm.loginStatus) {
                    
                }
                Spacer()
                
                if let buttonVisibility = vm.buttonVisibility {
                    if buttonVisibility == true {
                        if let title = vm.buttonTitle {
                            Button(title, action: {
                                if vm.loginStatus == .getConstantsButton {
                                    authState.getiCloudConstants()
                                } else if vm.loginStatus == .todoistAuthButton {
                                    authState.sendToTodoistAuthPage()
                                } else if vm.loginStatus == .todoistGetTokenButton {
                                    authState.getToken()
                                }
                                
                            })
                        }
                    }
                }

                Spacer()
                Text("Logging in ... ")
            }
            
            ProgressViewCommon(spinner: $vm.spinner)
            
        }
        .onOpenURL(perform: { (url) in
            print("the url is \(url)")
        })
        .navigationBarTitle("Welcome", displayMode: .inline)

        .onAppear(perform: {
            vm.accessTokenAction()
        })
        .alert(isPresented: $vm.showingAlert) {
                    Alert(title: Text("ERROR"), message: Text("Please try again."), dismissButton: .default(Text("Got it!")))
                }

    }
    
}

struct Welcome_Previews: PreviewProvider {
    @State static var showingAlert = false
    @State static var spinner = false
    @State static var buttonTitle = ""
    @State static var buttonVisibility = false
    
    static var previews: some View {
        Welcome (loginState: .constant(.complete), showingAlert: $showingAlert, spinner: $spinner, buttonTitle: .constant(""), buttonVisibility: .constant(false))


    }
}
