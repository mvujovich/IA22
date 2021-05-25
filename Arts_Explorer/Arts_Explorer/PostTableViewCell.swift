//
//  PostTableViewCell.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 24/5/2021.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var userTopLabel: UILabel!
    
    @IBOutlet var titleText: UILabel!
    
    @IBOutlet var descriptionText: UITextView!
    
    static let identifier = "PostTableViewCell"
    
    //Helps register cell with table view
    static func nib() -> UINib {
        return UINib(nibName: "PostTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with model: AEPost) {
        self.userTopLabel.text = "\(model.op)"
        self.titleText.text = "\(model.title)"
        self.descriptionText.text = "\(model.description)"
        self.userImageView.image = UIImage(named: "selfie")
        self.postImageView.image = UIImage(named: "23")
    }
    
}

struct AEPost {
    var id: String
    var op: String //uid of OP
    var approved: Bool
    var comments: Array<String> //Comment IDs
    //Use this -- var categories: Array<String> -- later
    var category: String
    var mediaID: String //Media in Firebase Storage
    var title: String
    var description: String
}
