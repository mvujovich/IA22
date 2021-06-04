//
//  OtherProfileViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 1/6/2021.
//

import UIKit
import Firebase

class OtherProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var otherUserID: String = ""
    
    var otherUserName: String = ""
    
    var postsToShow = [AEPost]()
    
    @IBOutlet weak var othProfPostListTableView: UITableView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        othProfPostListTableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        othProfPostListTableView.rowHeight = UITableView.automaticDimension
        othProfPostListTableView.delegate = self
        othProfPostListTableView.dataSource = self
        nameLabel.text = "\(otherUserName)"
        bioLabel.text = "bio"
        loadPosts()
        // Do any additional setup after loading the view.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = othProfPostListTableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.configure(with: postsToShow[indexPath.row])
        return cell
    }
    
    func loadPosts() {
        
        let firestore = Firestore.firestore()
        firestore.collection("posts").whereField("opID", isEqualTo: otherUserID)
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
                        self.othProfPostListTableView.insertRows(at: [indexPath], with: .automatic)
                            
                        }
                    }
                }
        }
    
    // MARK: - Instructions

    //  In a storyboard-based application, you will often want to do a little preparation before navigation override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
}
