//
//  Comment.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 16/4/2021.
//

import Foundation

class Comment {
    
    var content: String
    var commenter: String //uid of commenter
    var approved: Bool
    var op: String
    var post: String //id of post
    
    init(content: String, commenter: String, approved: Bool, op: String, post: String) {
        self.content = content
        self.commenter = commenter
        self.approved = approved
        self.op = op
        self.post = post
    }

}
