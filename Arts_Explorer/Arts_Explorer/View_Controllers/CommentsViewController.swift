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
    
    @IBOutlet weak var commentListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Comments on \(opName)'s post"
        
        commentListTableView.register(CommentTableViewCell.nib(), forCellReuseIdentifier: CommentTableViewCell.identifier)
        commentListTableView.rowHeight = UITableView.automaticDimension
        commentListTableView.delegate = self
        commentListTableView.dataSource = self
        
        let c1: Comment = Comment(message: "message 1 is very long and therefore i will be testing the ability of the table view to show all of the text. if this cut off it would be quite sad.", commenterName: "commenter name 1", commenterID: "commenter id 1", approved: true, postID: "post id 1")
        commentsToShow.append(c1)
        
        let c2: Comment = Comment(message: "message 2", commenterName: "commenter name 2", commenterID: "commenter id 2", approved: true, postID: "post id 2")
        commentsToShow.append(c2)
        
        let c3: Comment = Comment(message: "message 3", commenterName: "commenter name 3", commenterID: "commenter id 3", approved: true, postID: "post id 3")
        commentsToShow.append(c3)
        
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
    
    func loadComments()
    {
        for _ in commentsToShow
        {
            let indexPath = IndexPath(row: commentsToShow.count-1, section: 0)
            self.commentListTableView.insertRows(at: [indexPath], with: .automatic)
        }
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
