//
//  TaskListDetail.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/12/21.
//

import Foundation
import SwiftUI

struct TaskListDetail: View {

    @EnvironmentObject var taskListVM:TaskListViewModel
    
    @StateObject var vm:TaskListDetailViewModel = TaskListDetailViewModel()
    
    var task:Task

    init (task:Task) {
        print("taskListDetail init")
        self.task = task

    }
    
    var body: some View {
        HStack {
            Text(vm.task?.content ?? "?")
            VStack {

                Toggle(isOn: $vm.deleteState) {

                    Text("DELETE").frame(maxWidth: .infinity, alignment: .trailing)
                }

                Toggle(isOn: $vm.completeState) {
                    Text("COMPLETE").frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .onAppear {
            vm.setUp(task: self.task, taskListVM: self.taskListVM)
        }
        .onDisappear(perform: {
            //vm.deleteTaskSub?.cancel()
            //vm.completeTaskSub?.cancel()
        })
    }
    
}

struct TaskListDetail_Previews: PreviewProvider {
    private static var testTask = Task()
    static var previews: some View {
        TaskListDetail(task: testTask)
    }
}










