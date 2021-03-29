//
//  TaskList.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/12/21.
//

import Foundation
import SwiftUI

struct TaskList: View {

    @StateObject var vm:TaskListViewModel = TaskListViewModel()
    
    
    var projectID:Int?
    var taskContent:String
    
    init(projectID:Int?, taskContent:String) {
        print("taskList init")

        
        self.projectID = projectID
        self.taskContent = taskContent

    }
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    if let tasksTemp = vm.tasks {
                        ForEach(tasksTemp, id: \.id, content: {
                            task in
                            if let tempTask = task {
                                TaskListDetail(task: tempTask).environmentObject(vm)
                            }
                        })
                    }
                    
                }
                Button("CREATE") {
                    vm.createTask()

                }
            }
            ProgressViewCommon(spinner: $vm.spinner)

        }
        
        .navigationBarTitle("Task list", displayMode: .inline)
        .onAppear() {
            vm.setUp(projectID: projectID, taskContent: taskContent)
            vm.loadTasks()

        }
        .onDisappear(perform: {
            vm.createTaskSub?.cancel()
            vm.loadTaskSub?.cancel()
        })
    }
}




struct TaskList_Previews: PreviewProvider {
    static var projectID:Int? = 5
    
    static var previews: some View {
        TaskList(projectID: projectID, taskContent: "content")

    }
}
