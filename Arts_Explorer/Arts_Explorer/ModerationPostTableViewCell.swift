//
//  ModerationPostTableViewCell.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 13/6/2021.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI
import SDWebImage

class ModerationPostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameText: UILabel!
    
    @IBOutlet weak var postTitleText: UILabel!
    
    @IBOutlet weak var postDescriptionText: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postCategoriesText: UILabel!
    
    var callBackOnApproveButton: (()->())?
    
    var callBackOnDenyButton: (()->())?
    
    static let identifier = "ModerationPostTableViewCell"
    
    //Helps register cell with table view
    static func nib() -> UINib {
        return UINib(nibName: "ModerationPostTableViewCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated) }
    
    //MARK: - Configure
    
    ///This function allows the table view cell to display the contents of a Post for moderation.
    func configure(with model: AEPost)
    {
        if (model.mediaID != "")
        {
            let storageRef = Storage.storage().reference(withPath: "posts/\(model.id)")
            // Load the image using SDWebImage and FirebaseUI stuff
            self.postImageView.sd_setImage(with: storageRef, placeholderImage: nil)
        }
        else
        {
            self.postImageView.image = nil
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
                self.postTitleText.text = Constants.postNotFoundError
            }
        }
        userNameText.text = model.opName
        postTitleText.text = model.title
        postDescriptionText.text = model.description
        
        let tempCategoryString = model.categories.joined(separator: ", ")
        var finalCategoryString = tempCategoryString.first?.uppercased() ?? ""
        finalCategoryString.append(String(tempCategoryString.dropFirst()))
        postCategoriesText.text = finalCategoryString
        
    }
    
    //MARK: - Closures
    
    ///This function is connected to a closure that approves the post through Firestore.
    @IBAction func pressedApproveButton(_ sender: Any)
    {
        self.callBackOnApproveButton?()
    }
    
    ///This function is connected to a closure that removes the post through Firestore.
    @IBAction func pressedDenyButton(_ sender: Any)
    {
        self.callBackOnDenyButton?()
    }
    
}
