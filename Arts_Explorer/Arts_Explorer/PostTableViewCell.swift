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
    
    @IBOutlet weak var saveButton: UIButton!
    
    var callBackOnCommentButton: (()->())?
    
    var postID: String = ""
    
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
     
    ///This function allows the table view cell to display the contents of an AEPost.
    func configure(with model: AEPost) {
        if (model.mediaID != "") //Post has image
        {
            let storageRef = Storage.storage().reference(withPath: "posts/\(model.id)")
            // Load the image using SDWebImage and FirebaseUI
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
                    //Load image using SDWebImage and FirebaseUI
                    self.userImageView.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder-profile"))
                }
                else
                {
                    self.userImageView.image = UIImage(named: "placeholder-profile")
                }
            let opID = Auth.auth().currentUser!.uid as String
            //Call to Firestore: if post has been saved by current user, fill save button
            self.fillSaveButtons(currentUser: opID)
            } else {
                self.titleText.text = Constants.postNotFoundError
            }
        }
        //Fills other fields using model
        self.userTopLabel.text = "\(model.opName)"
        self.titleText.text = "\(model.title)"
        self.descriptionText.text = "\(model.description)"
        self.postID = model.id
    }
    
    ///This function triggers a closure which opens the comment view of a Post.
    @IBAction func pressedViewComments(_ sender: Any)
    {
        self.callBackOnCommentButton?()
    }
    
    ///This function edits Firestore and changes the appearance of the save button when it is pressed.
    @IBAction func pressedSaveButton(_ sender: Any)
    {
        let firestore = Firestore.firestore()
        let opID = Auth.auth().currentUser!.uid as String
        let userReference = firestore.collection("users").document(opID)

        if (saveButton.isSelected)
        {
            saveButton.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
            userReference.updateData([
                "savedPosts": FieldValue.arrayRemove([postID])
            ])
            saveButton.isSelected = false
        }
        else
        {
            saveButton.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            userReference.updateData([
                "savedPosts": FieldValue.arrayUnion([postID])
            ])
            saveButton.isSelected = true
        }
    }
    
    ///This function allows for the table view cells to be displayed smoothly.
    override func prepareForReuse() {
        super.prepareForReuse()
        let opID = Auth.auth().currentUser!.uid as String
        fillSaveButtons(currentUser: opID)
    }
    
    ///This function loads in the appearance of all save buttons in cells by checking with Firebaseu.
    func fillSaveButtons(currentUser: String)
    {
        let firestore = Firestore.firestore()
        let userReference = firestore.collection("users").document(currentUser)
        var savedPosts = [String]()
        userReference.getDocument { (document, error) in
            if let document = document, document.exists {
                savedPosts = document.get("savedPosts") as! Array<String>
                if (savedPosts.contains(self.postID))
                {
                    self.saveButton.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                }
                else
                {
                    self.saveButton.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
                }
            } else {
                //No need for any action
            }
        }
    }

}

//MARK: - AEPost struct

struct AEPost {
    var id: String
    var opID: String //uid of OP
    var opName: String
    var approved: Bool
    var categories: Array<String>
    var mediaID: String //Media in Firebase Storage
    var title: String
    var description: String
    var time: Timestamp
}

/*
Backup for plain Firebase Storage code -- not used at the moment
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
