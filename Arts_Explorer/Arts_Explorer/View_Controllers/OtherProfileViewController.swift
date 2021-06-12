//
//  OtherProfileViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 1/6/2021.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI
import SDWebImage

class OtherProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var otherUserID: String = ""
    
    var otherUserName: String = ""
    
    var postsToShow = [AEPost]()
    
    @IBOutlet weak var othProfPostListTableView: UITableView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            othProfPostListTableView.refreshControl = refreshControl
        } else {
            othProfPostListTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(reloadPosts(_:)), for: .valueChanged)
        
        othProfPostListTableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        othProfPostListTableView.rowHeight = UITableView.automaticDimension
        othProfPostListTableView.delegate = self
        othProfPostListTableView.dataSource = self
        loadInfo()
        loadPosts()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - General setup
    
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
    
    func loadInfo()
    {
        let firestore = Firestore.firestore()
        
        let docRef = firestore.collection("users").document(otherUserID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let opName = document.get("name") as! String
                self.nameLabel.text = opName
                let opBio = document.get("bio") as! String
                self.bioLabel.text = opBio
                let opAvatarID = document.get("avatarID") as! String
                if (opAvatarID != "")
                {
                    let storageRef = Storage.storage().reference(withPath: "avatars/\(opAvatarID)")
                    self.profilePictureImageView.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder-profile"))
                }
                else
                {
                    self.profilePictureImageView.image = UIImage(named: "placeholder-profile")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    //MARK: - Loading posts
    
    func loadPosts() {
        let firestore = Firestore.firestore()
        firestore.collection("posts").whereField("opID", isEqualTo: otherUserID).order(by: "time", descending: true).limit(to: 15).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let postID: String = document.get("id") as! String
                        let postOPID: String = document.get("opID") as! String
                        let postOPName: String = document.get("opName") as! String
                        let postCategories: Array<String> = document.get("categories") as! Array<String>
                        let mediaID: String = document.get("mediaID") as! String
                        let postTitle: String = document.get("title") as! String
                        let postDescription: String = document.get("description") as! String
                        let postTime: Timestamp = document.get("time") as! Timestamp
                        let post: AEPost = AEPost(id: postID, opID: postOPID, opName: postOPName, approved: true, categories: postCategories, mediaID: mediaID, title: postTitle, description: postDescription, time: postTime)
                        self.postsToShow.append(post)
                        let indexPath = IndexPath(row: self.postsToShow.count-1, section: 0)
                        self.othProfPostListTableView.insertRows(at: [indexPath], with: .automatic)
                            
                        }
                    }
                }
        self.refreshControl.endRefreshing()
    }
    
    @objc func reloadPosts(_ sender: Any) {
        self.loadPosts()
    }
    
    // MARK: - Instructions

    //  In a storyboard-based application, you will often want to do a little preparation before navigation override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
}
