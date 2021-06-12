//
//  CommentTableViewCell.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 12/6/2021.
//

import UIKit
import Firebase

class CommentTableViewCell: UITableViewCell, UITextViewDelegate {
    
    
    @IBOutlet weak var commenterName: UILabel!
    
    @IBOutlet weak var message: UILabel!
    
    static let identifier = "CommentTableViewCell"
    
    //Helps register cell with table view
    static func nib() -> UINib {
        return UINib(nibName: "CommentTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: Comment) {
        self.message.text = model.message
        self.commenterName.text = model.commenterName
    }
    
}

struct Comment {
    var message: String
    var commenterName: String //name of commenter
    var commenterID: String
    var approved: Bool
    var postID: String //id of post
    //var time: Timestamp
}
