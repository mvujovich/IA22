//
//  ModerationPostViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 13/6/2021.
//

import UIKit
import Firebase

class ModerationPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var pendingPostListTableView: UITableView!
    
    var postsToShow = [AEPost]()
    
    var opID: String = ""
    
    var opName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        pendingPostListTableView.register(ModerationPostTableViewCell.nib(), forCellReuseIdentifier: ModerationPostTableViewCell.identifier)
        pendingPostListTableView.rowHeight = UITableView.automaticDimension
        pendingPostListTableView.delegate = self
        pendingPostListTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        loadPendingPosts()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToShow.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //postListTableView.deselectRow(at: indexPath, animated: true)
        //performSegue(withIdentifier: "showProfileFromModerationPost", sender: indexPath) //fix this
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = pendingPostListTableView.dequeueReusableCell(withIdentifier: ModerationPostTableViewCell.identifier, for: indexPath) as! ModerationPostTableViewCell //fix
        cell.configure(with: postsToShow[indexPath.row])
        
        cell.callBackOnApproveButton = {
            let postID = self.postsToShow[indexPath.row].id
            let firestore = Firestore.firestore()
            firestore.collection("posts").document(postID).updateData(["approved": true])
            self.postsToShow.remove(at: indexPath.row)
            self.pendingPostListTableView.deleteRows(at: [indexPath], with: .fade)
            //delete from table view
        }
        
        cell.callBackOnDenyButton = {
            let postID = self.postsToShow[indexPath.row].id
            let firestore = Firestore.firestore()
            firestore.collection("posts").document(postID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)") //MARK: - Fix
                } else {
                    print("Document successfully removed!")
                    self.postsToShow.remove(at: indexPath.row)
                    self.pendingPostListTableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
        
        return cell
    }
    
    //MARK: - Load posts
    
    func loadPendingPosts() {
        let firestore = Firestore.firestore()
        firestore.collection("posts").whereField("approved", isEqualTo: false).order(by: "time", descending: false).limit(to: 15).getDocuments()
        { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.postsToShow.removeAll()
                    self.pendingPostListTableView.reloadData()
                    for document in querySnapshot!.documents
                    {
                        let postID: String = document.get("id") as! String
                        let postOPID: String = document.get("opID") as! String
                        let postOPName: String = document.get("opName") as! String
                        //Do comments later
                        let postCategories: Array<String> = document.get("categories") as! Array<String>
                        let mediaID: String = document.get("mediaID") as! String
                        let postTitle: String = document.get("title") as! String
                        let postDescription: String = document.get("description") as! String
                        let postTime: Timestamp = document.get("time") as! Timestamp
                        let post: AEPost = AEPost(id: postID, opID: postOPID, opName: postOPName, approved: true, categories: postCategories, mediaID: mediaID, title: postTitle, description: postDescription, time: postTime)
                        self.postsToShow.append(post)
                        let indexPath = IndexPath(row: self.postsToShow.count-1, section: 0)
                        self.pendingPostListTableView.insertRows(at: [indexPath], with: .automatic)
                    }
                    if (self.postsToShow.isEmpty)
                    {
                        self.createAlert(title: "All done!", message: "There are no posts currently pending.")
                    }
                }
            }
    }
    
    //MARK: - Alert
    
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    

    /*
    //

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
