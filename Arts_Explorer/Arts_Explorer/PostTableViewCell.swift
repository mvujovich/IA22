//
//  PostTableViewCell.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 24/5/2021.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI
import SDWebImage

class PostTableViewCell: UITableViewCell, UITextViewDelegate {
    
    //MARK: - Declare variables, etc.
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var userTopLabel: UILabel!
    
    @IBOutlet var titleText: UILabel!
    
    @IBOutlet weak var descriptionText: UILabel!
        
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
        super.setSelected(selected, animated: animated) }
    
//MARK: - Configure
     
    func configure(with model: AEPost) {
        if (model.mediaID != "")
        {
            let storageRef = Storage.storage().reference(withPath: "posts/\(model.id)")
            // Load the image using SDWebImage and FirebaseUI stuff
            self.postImageView.sd_setImage(with: storageRef, placeholderImage: nil)
            
            /*
            Backup for plain Firebase Storage code
            storageRef.getData(maxSize: 1024 * 1024) { [weak self](data, error) in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }
                if let data = data {
                    let image = UIImage(data: data)
                    self?.postImageView.image = UIImage(data: data)
                }
            }
            */
        }
        else
        {
            self.postImageView.image = nil //Replace this with a placeholder
        }
        
        //Get user avatar
        let firestore = Firestore.firestore()
        let docRef = firestore.collection("users").document("\(model.opID)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let avatarID = document.get("avatarID") as! String
                if (avatarID != "")
                {
                    let storageRef = Storage.storage().reference(withPath: "avatars/\(avatarID)")
                    self.userImageView.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder-profile"))
                }
                else
                {
                    self.userImageView.image = UIImage(named: "placeholder-profile")
                }
            } else {
                print("Document does not exist")
            }
        }
        self.userTopLabel.text = "\(model.opName)"
        self.titleText.text = "\(model.title)"
        self.descriptionText.text = "\(model.description)"
        self.userImageView.image = UIImage(named: "selfie")
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
