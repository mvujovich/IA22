//
//  CommentsViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 11/6/2021.
//

import UIKit
import Firebase

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var postID: String = ""
    
    var opName: String = ""
    
    var commentsToShow = [Comment]()

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var commentListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Comments on \(opName)'s post"
        
        commentListTableView.register(CommentTableViewCell.nib(), forCellReuseIdentifier: CommentTableViewCell.identifier)
        commentListTableView.rowHeight = UITableView.automaticDimension
        commentListTableView.delegate = self
        commentListTableView.dataSource = self
        
        loadComments()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentListTableView.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
        cell.configure(with: commentsToShow[indexPath.row])
        return cell
    }
    
    ///This function loads all comments from the given post (from Firebase) into the table view.
    func loadComments()
    {
        let firestore = Firestore.firestore()
        firestore.collection("comments").whereField("postID", isEqualTo: self.postID).whereField("approved", isEqualTo: true).order(by: "time", descending: true).limit(to: 20).addSnapshotListener()
        { (querySnapshot, err) in
                if let err = err {
                    self.createAlert(title: "Error", message: "Error getting documents: \(err.localizedDescription)")
                } else {
                    self.commentsToShow.removeAll()
                    self.commentListTableView.reloadData()
                    for document in querySnapshot!.documents
                    {
                        let storedCommentID: String = document.get("commentID") as! String
                        let storedMessage: String = document.get("message") as! String
                        let storedCommenterName: String = document.get("commenterName") as! String
                        let storedCommenterID: String = document.get("commenterID") as! String
                        let storedPostID: String = document.get("postID") as! String
                        let storedTime: Timestamp = document.get("time") as! Timestamp
                        let comment: Comment = Comment(commentID: storedCommentID, message: storedMessage, commenterName: storedCommenterName, commenterID: storedCommenterID, approved: true, postID: storedPostID, time: storedTime)
                        self.commentsToShow.append(comment)
                        let indexPath = IndexPath(row: self.commentsToShow.count-1, section: 0)
                        self.commentListTableView.insertRows(at: [indexPath], with: .automatic)
                    }
                }
            }
    }
    
    ///This function sends a comment to Firebase with the text entered by the user.
    @IBAction func sendCommentPressed(_ sender: Any)
    {
        let message: String = commentTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if message == "" {
            createAlert(title: "Error", message: Constants.emptyCommentError)
        }
        else {
            let commentID = UUID().uuidString
            let opID = Auth.auth().currentUser!.uid as String

            let firestore = Firestore.firestore()
            var opName: String = ""
            let docRef = firestore.collection("users").document(opID)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    opName = document.get("name") as! String
                    firestore.collection("comments").document(commentID).setData(
                                [   //Data saved in Dictionary
                                    "commentID": commentID,
                                    "message": message,
                                    "commenterName": opName,
                                    "commenterID": opID,
                                    "approved": false,
                                    "postID": self.postID,
                                    "time": Timestamp(date: Date())
                                ])
                                { (error) in
                                    if error != nil
                                    {
                                        self.createAlert(title: "Error", message: Constants.postingCommentError)
                                    }
                                }
                            self.commentTextField.text = ""
                        }
                else
                {
                    self.createAlert(title: "Error", message: Constants.unknownUserError)
                }
            } //End larger async
        }
    }
    
    ///This function creates popup alerts for errors and success messages.
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }

}
