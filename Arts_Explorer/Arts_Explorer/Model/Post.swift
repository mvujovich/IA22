//
//  Post.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 16/4/2021.
//

import Foundation

class Post {
    
    var id: String
    var op: String //uid of OP
    var approved: Bool
    var comments: Array<String> //Comment IDs
    var categories: Array<String>
    var mediaID: String //Media in Firebase Storage
    var title: String
    var description: String
    
    init(id: String, op: String, approved: Bool, comments: Array<String>, categories: Array<String>, mediaID: String, title: String, description: String) {
        self.id = id
        self.op = op
        self.approved = approved
        self.comments = comments
        self.categories = categories
        self.mediaID = mediaID
        self.title = title
        self.description = description
    }

}
