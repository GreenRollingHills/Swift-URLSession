//
//  ImageDump.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/11/21.
//

import Foundation

import SwiftUI

struct ItemList: View {


    @StateObject var vm = ItemListViewModel()
    
    var navigationLink: NavigationLink<EmptyView, ProjectList>? {
        guard let item = vm.selectedItem else {
                return nil
        }
        
        return NavigationLink(
            destination: ProjectList(taskContent: vm.selectedItem ?? "?"),
            tag:  item,
            selection: $vm.selectedItem

        ) {
            EmptyView()
        }
    }
    
    var body: some View {
        VStack {
            Text("Study What?")
            ZStack {
                navigationLink
                List {
                    ForEach(vm.studyList, id: \.self, content: {
                        item in
                        
                        Button(item, action: {
                            vm.selectedItem = item

                        })

                    })
                }
            }
            
        }
        .navigationBarTitle("Study list", displayMode: .inline)


    }
}

struct ItemList_Previews: PreviewProvider {
    static var previews: some View {
        ItemList()
    }
}
