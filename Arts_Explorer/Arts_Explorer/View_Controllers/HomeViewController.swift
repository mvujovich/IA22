//
//  HomeViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 15/4/2021.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var postListTableView: UITableView!
    
    //MARK: - Loading posts
    
    var postsToShow = [AEPost]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postListTableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        postListTableView.rowHeight = UITableView.automaticDimension
        postListTableView.delegate = self
        postListTableView.dataSource = self
        
        //TODO: Add support for posts without images
        //postListTableView.estimatedRowHeight = 300.0
        loadPosts()
        // Do any additional setup after loading the view.
    }
    
    func loadPosts() {
        
        let firestore = Firestore.firestore()
        firestore.collection("posts").whereField("approved", isEqualTo: true)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let postID: String = document.get("id") as! String
                        let postOPID: String = document.get("opID") as! String
                        let postOPName: String = document.get("opName") as! String
                        //Do comments and categories (proper) and media ID later
                        let postCategory: String = document.get("category") as! String
                        let mediaID: String = document.get("mediaID") as! String
                        let postTitle: String = document.get("title") as! String
                        let postDescription: String = document.get("description") as! String
                        let commentsArray = [""] //Fix this later, obviously
                        let post: AEPost = AEPost(id: postID, opID: postOPID, opName: postOPName, approved: true, comments: commentsArray, category: postCategory, mediaID: mediaID, title: postTitle, description: postDescription)
                        self.postsToShow.append(post)
                        let indexPath = IndexPath(row: self.postsToShow.count-1, section: 0)
                        self.postListTableView.insertRows(at: [indexPath], with: .automatic)
                            
                        }
                    }
                }
        }
    
    //MARK: - Table View specifics
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToShow.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        postListTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showProfileFromPost", sender: self)
    }
    
    //func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = postListTableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier) as! PostTableViewCell
//        cell.configure(with: postsToShow[indexPath.row])
//        let textViewHeight = cell.descriptionText.frame.size.height
//        return textViewHeight+129+view.frame.size.width
        
    //}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = postListTableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.configure(with: postsToShow[indexPath.row])
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
