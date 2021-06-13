//
//  ModerationCommentViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 13/6/2021.
//

import UIKit
import Firebase

class ModerationCommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pendingCommentListTableView: UITableView!

    var commentsToShow = [Comment]()
    
    var opID: String = ""
        
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            pendingCommentListTableView.refreshControl = refreshControl
        } else {
            pendingCommentListTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(reloadPendingComments(_:)), for: .valueChanged)

        pendingCommentListTableView.register(ModerationCommentTableViewCell.nib(), forCellReuseIdentifier: ModerationCommentTableViewCell.identifier) //FIX
        pendingCommentListTableView.rowHeight = UITableView.automaticDimension
        pendingCommentListTableView.delegate = self
        pendingCommentListTableView.dataSource = self
        
        loadPendingComments()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pendingCommentListTableView.dequeueReusableCell(withIdentifier: ModerationCommentTableViewCell.identifier, for: indexPath) as! ModerationCommentTableViewCell //fix
        cell.configure(with: commentsToShow[indexPath.row])
        
        cell.callBackOnApproveButton = {
            let commentID = self.commentsToShow[indexPath.row].commentID
            let firestore = Firestore.firestore()
            firestore.collection("comments").document(commentID).updateData(["approved": true])
            self.commentsToShow.remove(at: indexPath.row)
            self.pendingCommentListTableView.deleteRows(at: [indexPath], with: .fade)
            self.pendingCommentListTableView.reloadData()
            //delete from table view
        }
        
        cell.callBackOnDenyButton = {
            let commentID = self.commentsToShow[indexPath.row].commentID
            let firestore = Firestore.firestore()
            firestore.collection("comments").document(commentID).delete() { err in
                if let err = err {
                    self.createAlert(title: "Error", message: "Error removing comment: \(err.localizedDescription)")
                } else {
                    //No need to notify moderator of success
                    self.commentsToShow.remove(at: indexPath.row)
                    self.pendingCommentListTableView.deleteRows(at: [indexPath], with: .fade)
                    self.pendingCommentListTableView.reloadData()
                }
            }
        }
        
        return cell
    }
    
    //MARK: - Load posts
    
    func loadPendingComments() {
        let firestore = Firestore.firestore()
        firestore.collection("comments").whereField("approved", isEqualTo: false).order(by: "time", descending: false).limit(to: 20).getDocuments()
        { (querySnapshot, err) in
                if let err = err {
                    self.createAlert(title: "Error", message: "Error getting comments: \(err.localizedDescription)")
                } else {
                    self.commentsToShow.removeAll()
                    self.pendingCommentListTableView.reloadData()
                    for document in querySnapshot!.documents
                    {
                        let storedCommentID: String = document.get("commentID") as! String
                        let storedMessage: String = document.get("message") as! String
                        let storedCommenterName: String = document.get("commenterName") as! String
                        let storedCommenterID: String = document.get("commenterID") as! String
                        let storedPostID: String = document.get("postID") as! String
                        let storedTime: Timestamp = document.get("time") as! Timestamp
                        let comment: Comment = Comment(commentID: storedCommentID, message: storedMessage, commenterName: storedCommenterName, commenterID: storedCommenterID, approved: false, postID: storedPostID, time: storedTime)
                        self.commentsToShow.append(comment)
                        let indexPath = IndexPath(row: self.commentsToShow.count-1, section: 0)
                        self.pendingCommentListTableView.insertRows(at: [indexPath], with: .automatic)
                    }
                    if (self.commentsToShow.isEmpty)
                    {
                        self.createAlert(title: "All done!", message: "There are no comments currently pending.")
                    }
                }
            }
        self.refreshControl.endRefreshing()
    }
    
    //MARK: - Reload
    
    @objc func reloadPendingComments(_ sender: Any) {
        self.loadPendingComments()
    }
    
    //MARK: - Alert
    
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
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
