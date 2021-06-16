//
//  SavedViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 9/6/2021.
//

import UIKit
import Firebase

class SavedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var savedPostListTableView: UITableView!
    var postsToShow = [AEPost]()
    var savedPosts = [String]()
    
    //For opening comments
    var opID: String = ""
    var opName: String = ""
    var postID: String = ""
    
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        savedPostListTableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        savedPostListTableView.rowHeight = UITableView.automaticDimension
        savedPostListTableView.delegate = self
        savedPostListTableView.dataSource = self
        
        if #available(iOS 10.0, *) {
            savedPostListTableView.refreshControl = refreshControl
        } else {
            savedPostListTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(reloadSavedPosts(_:)), for: .valueChanged)
        
        loadSavedPosts()

        // Do any additional setup after loading the view.
    }
    
    //MARK: - Load saved posts
    
    ///This function loads all posts saved by the current user (from Firestore) into the table view.
    func loadSavedPosts() {
        let firestore = Firestore.firestore()
        let opID = Auth.auth().currentUser!.uid as String
        let userReference = firestore.collection("users").document(opID)
        userReference.getDocument { (document, error) in
            if let document = document, document.exists {
                self.savedPosts = document.get("savedPosts") as! Array<String>
                //List of saved post IDs now filled
                //Unfortunately, they're random in order. This can/will be improved!
                
                self.postsToShow.removeAll()
                self.savedPostListTableView.reloadData()
                for postID in self.savedPosts
                {
                    let postReference = firestore.collection("posts").document(postID)
                    postReference.getDocument { (document, error) in
                        if let document = document, document.exists {
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
                            self.savedPostListTableView.insertRows(at: [indexPath], with: .automatic)
                        }
                        else {
                            self.createAlert(title: "Error", message: "Saved posts could not be retrieved.")
                        }
                        
                    }
                }
            } else {
                self.createAlert(title: "Error", message: "Saved posts could not be retrieved.")
            }
        }
        self.refreshControl.endRefreshing()
    }
    
    ///This function uses the refresh controller to reload posts.
    @objc func reloadSavedPosts(_ sender: Any) {
        self.loadSavedPosts()
    }
    
    ///This function creates popup alerts for errors and success messages.
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Table view specifics
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToShow.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //postListTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showProfileFromSaved", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savedPostListTableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.configure(with: postsToShow[indexPath.row])
        
        cell.callBackOnCommentButton = {
            self.prepareInfo(indexPath: indexPath)
            self.performSegue(withIdentifier: "showCommentsFromSaved", sender: nil)
        }
        return cell
    }
    
    ///This function prepares the user for segues (to comment view, etc).
    func prepareInfo(indexPath: IndexPath)
    {
        opID = postsToShow[indexPath.row].opID
        opName = postsToShow[indexPath.row].opName
        postID = postsToShow[indexPath.row].id
    }
    
    //MARK: - Segue prep
    
    ///This function prepares for segues to the comment view of posts and profiles of other posters.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProfileFromSaved" {
                if let indexPath = self.savedPostListTableView.indexPathForSelectedRow  {
                    let otherProfileViewController = segue.destination as! OtherProfileViewController
                    prepareInfo(indexPath: indexPath)
                    otherProfileViewController.otherUserID = opID
                    otherProfileViewController.otherUserName = opName
                }
        }
        
        if segue.identifier == "showCommentsFromSaved"
        {
            let commentsViewController = segue.destination as! CommentsViewController
            commentsViewController.postID = postID
            commentsViewController.opName = opName
        }
    }
}
