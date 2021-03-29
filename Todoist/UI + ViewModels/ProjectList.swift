//
//  ProjectList.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/12/21.
//

import Foundation
import SwiftUI


struct ProjectList: View {
       
    @StateObject var vm:ProjectListViewModel = ProjectListViewModel()
    
    var taskContent:String? = nil

    init(taskContent:String) {

        self.taskContent = taskContent
    }
    
    var body: some View {
        ZStack {
            VStack {
                Text("Add Where ?")
                List {

                    if let projectsTemp = vm.projects {
                        ForEach(projectsTemp, id: \.id, content: {
                            project in


                            NavigationLink(destination: TaskList(projectID: project.id, taskContent: taskContent ?? "?"),
                                label: {
                                    if let tempName = project.name {
                                        Text(tempName)
                                    }
                                })
                        })
                        
                    }
                    
                }
                
                
            }
            ProgressViewCommon(spinner: $vm.spinner)
        }
        .navigationBarTitle("Poject list", displayMode: .inline)
        .onAppear {
            vm.loadProjects()
        }
        .onDisappear(perform: {
            print("onDisappear")
            vm.subscriber?.cancel()
        })
        
    }
}

struct ProjectList_Previews: PreviewProvider {
    static var previews: some View {
        ProjectList(taskContent: "content")
    }
}


