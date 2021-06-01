//
//  PostTableViewCell.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 24/5/2021.
//

import UIKit
import Firebase
import FirebaseStorage

class PostTableViewCell: UITableViewCell, UITextViewDelegate {
    
    //MARK: - Declare variables, etc.
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var userTopLabel: UILabel!
    
    @IBOutlet var titleText: UILabel!
    
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var hiddenOPIDText: UILabel!
    
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
    
//MARK: - Configure
     
    func configure(with model: AEPost) {
        //print("id is \(model.id)")
        //print("media id is \(model.mediaID)")
        //print("user id is \(model.opID)")
        //print("user name is \(model.opName)")
        if (model.mediaID != "")
        {
            //print("MEDIA ID EXISTS")
            let storageRef = Storage.storage().reference(withPath: "posts/\(model.id)")
            storageRef.getData(maxSize: 1024 * 1024) { [weak self](data, error) in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }
                if let data = data {
                    self?.postImageView.image = UIImage(data: data)
                }
            }
        }
        else
        {
            self.postImageView.image = nil
        }
        self.userTopLabel.text = "\(model.opName)"
        self.titleText.text = "\(model.title)"
        self.descriptionText.text = "\(model.description)"
        self.userImageView.image = UIImage(named: "selfie")
        self.hiddenOPIDText.text = "\(model.opID)"
        self.hiddenOPIDText.alpha = 0
    }

}

//MARK: - AEPost struct

struct AEPost {
    var id: String
    var opID: String //uid of OP
    var opName: String
    var approved: Bool
    var comments: Array<String> //Comment IDs
    //Use this -- var categories: Array<String> -- later
    var category: String
    var mediaID: String //Media in Firebase Storage
    var title: String
    var description: String
}
