//
//  User.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 16/4/2021.
//

import Foundation

class User {
    
    var id: String
    var name: String
    var mod: Bool
    var posts: Array<String> //post IDs
    var savedPosts: Array<String> //post IDs
    var avatarID: String //ID of image in Firebase Storage
    var bio: String
    
    init(id: String, name: String, mod: Bool, posts: Array<String>, savedPosts: Array<String>, avatarID: String, bio: String) {
        self.id = id
        self.name = name
        self.mod = mod
        self.posts = posts
        self.savedPosts = savedPosts
        self.avatarID = avatarID
        self.bio = bio
    }
    
}
