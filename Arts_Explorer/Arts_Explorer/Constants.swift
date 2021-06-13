//
//  Constants.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 16/4/2021.
//

import Foundation

struct Constants {
    
    struct Storyboard {
        
        static let homeViewController = "homeViewController"
        static let homeBarController = "mainTabBarViewController"
    }
    
    //MARK: - Identifiers
    
    static let menuItemIdentifier = "menuItemCell"
    
    //MARK: - Profile info
    static let temporaryBio = "Your bio here"
    static let temporaryName = "Your name here"
    
    //MARK: - Categories
    static let artCategory = "art"
    static let dramaCategory = "drama"
    static let filmCategory = "film"
    static let musicCategory = "music"
    
    //MARK: - Error messages
    static let allFieldsEmptyError = "Please fill in at least one field."
    static let noCategoryError = "Please select at least one category."
    static let emptyCommentError = "Cannot post an empty comment."
    static let postingCommentError = "Comment could not be posted."
    static let unknownUserError = "User information could not be found."
    static let postNotFoundError = "[post not found]"
}
