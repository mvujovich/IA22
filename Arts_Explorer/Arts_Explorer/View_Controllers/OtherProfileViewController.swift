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
    
    //Used for segue to comment view
    var opID: String = ""
    var opName: String = ""
    var postID: String = ""
    
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
        
        cell.callBackOnCommentButton = {
            self.prepareInfo(indexPath: indexPath)
            self.performSegue(withIdentifier: "showCommentsFromOtherProfile", sender: nil)
        }
        return cell
    }
    
    ///This function prepares the user for segues (to comment view).
    func prepareInfo(indexPath: IndexPath)
    {
        opID = postsToShow[indexPath.row].opID
        opName = postsToShow[indexPath.row].opName
        postID = postsToShow[indexPath.row].id
    }
    
    ///This function sets up profile information about the given user.
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
                self.createAlert(title: "Error", message: Constants.unknownUserError)
            }
        }
    }
    
    //MARK: - Loading posts

    ///This function loads all approved posts made by the given user (from Firestore) into the table view.
    func loadPosts() {
        let firestore = Firestore.firestore()
        firestore.collection("posts").whereField("opID", isEqualTo: otherUserID).whereField("approved", isEqualTo: true).order(by: "time", descending: true).limit(to: 15).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    self.createAlert(title: "Error", message: "Error getting posts: \(err.localizedDescription)")
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
    
    ///This function uses the refresh controller to reload posts.
    @objc func reloadPosts(_ sender: Any) {
        self.loadPosts()
    }
    
    //MARK: - Alert
    
    ///This function creates popup alerts for errors and success messages.
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    ///This function prepares for segues to the comment view of posts.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCommentsFromOtherProfile"
        {
            let commentsViewController = segue.destination as! CommentsViewController
            commentsViewController.postID = postID
            commentsViewController.opName = opName
        }
    }
}
