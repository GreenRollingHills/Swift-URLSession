//
//  ItemListConfig.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/17/21.
//

import Foundation

class ItemListViewModel:ObservableObject {
    @Published var studyList:[String] = ["Math", "American History",
                                         "Roman History", "Social Studies",
                                         "American Literature", "Biology",
                                         "Spanish", "Chess"]

    @Published var selectedItem: String? = nil
    
}
