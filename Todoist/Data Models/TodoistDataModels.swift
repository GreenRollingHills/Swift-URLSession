//
//  TodoistData.swift
//  Todoist
//
//  Created by Eusebio Aguayo on 3/12/21.
//

import Foundation

struct ProjectResponse:Codable {
    var results:[Project]
}

struct Project:Hashable, Codable {
    var id:Int?
    var name:String?
    var comment_count:Int?
    var order:Int?
    var color:Int?
    var shared:Bool?
    var sync_id:u_long?
    var favorite:Bool?
    var inbox_project:Bool?
    var url:String?
    
    
}

struct Task: Codable {
    var id:Int?
    var project_id:Int?
    var section_id:Int?
    var parent_id:Int?
    var content:String?
    var comment_count:Int?
    var order:Int?
    var priority:Int?
    var url:String?
    
}

struct TodoistAuthData:Codable {
    var access_token:String?
    var token_type:String?
}

struct TodoistCodeData {
    var code:String?
    var secretStateReceived:String?
}
