//
//  UserProfileViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 1/6/2021.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseUI
import SDWebImage

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var selfPostListTableView: UITableView!
    
    @IBOutlet weak var selfProfilePicture: UIImageView!
    var avatarPicker = UIImagePickerController()
    
    @IBOutlet weak var selfName: UITextField!
    
    @IBOutlet weak var selfBio: UITextField!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var editingMode: Bool = false
    var postsToShow = [AEPost]()
    
    var opID = ""
    
    var originalNameText: String = ""
    var originalBioText: String = ""
    var originalAvatar: UIImage?
    
    let firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        opID = Auth.auth().currentUser!.uid as String
        selfPostListTableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        selfPostListTableView.rowHeight = UITableView.automaticDimension
        selfPostListTableView.delegate = self
        selfPostListTableView.dataSource = self
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tappedAvatar(_:)))
        tapRecognizer.delegate = self
        self.selfProfilePicture.addGestureRecognizer(tapRecognizer)
        
        loadPosts()
        loadInfo()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Loading posts
    
    func loadPosts() {
        firestore.collection("posts").whereField("opID", isEqualTo: opID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let postID: String = document.get("id") as! String
                        let postOPID: String = document.get("opID") as! String
                        let postOPName: String = document.get("opName") as! String
                        //Do comments and categories (proper) and media ID later
                        let postCategory: String = document.get("category") as! String
                        let mediaID: String = document.get("mediaID") as! String
                        let postTitle: String = document.get("title") as! String
                        let postDescription: String = document.get("description") as! String
                        let commentsArray = [""] //Fix this later, obviously
                        let post: AEPost = AEPost(id: postID, opID: postOPID, opName: postOPName, approved: true, comments: commentsArray, category: postCategory, mediaID: mediaID, title: postTitle, description: postDescription)
                        self.postsToShow.append(post)
                        let indexPath = IndexPath(row: self.postsToShow.count-1, section: 0)
                        self.selfPostListTableView.insertRows(at: [indexPath], with: .automatic)
                            
                        }
                    }
                }
        }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = selfPostListTableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.configure(with: postsToShow[indexPath.row])
        return cell
    }
    
    func loadInfo()
    {
        var opAvatarID = ""
        let docRef = firestore.collection("users").document(opID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let opName = document.get("name") as! String
                self.selfName.text = opName
                let opBio = document.get("bio") as! String
                self.selfBio.text = opBio
                opAvatarID = document.get("avatarID") as! String
                if (opAvatarID != "")
                {
                    let storageRef = Storage.storage().reference(withPath: "avatars/\(opAvatarID)")
                    self.selfProfilePicture.sd_setImage(with: storageRef, placeholderImage: UIImage(named: "placeholder-profile"))
                }
                else
                {
                    self.selfProfilePicture.image = UIImage(named: "placeholder-profile")
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    //MARK: - Editing profile info
    
    //Mr. Lagos is this an algorithm :( my brain hurts a bit so I hope so
    @IBAction func editTapped(_ sender: Any)
    {
        if editingMode
        {
            //Revert to non-editing mode
            editingMode = false
            self.title = "Profile"
            editButton.image = UIImage(systemName: "square.and.pencil")
            selfName.isUserInteractionEnabled = false
            selfBio.isUserInteractionEnabled = false
            selfProfilePicture.isUserInteractionEnabled = false
            
            //Send data to Firebase
            let newNameText: String = selfName.text!
            let newBioText: String = selfBio.text!
            let newAvatar: UIImage = selfProfilePicture.image!
            
            if (newBioText != originalBioText) && (newNameText != originalNameText) //Both have changed
            {
                firestore.collection("users").document(opID).updateData(["name": newNameText, "bio": newBioText])
            }
            else if (newNameText != originalNameText) //Only one has changed --> name changed
            {
                firestore.collection("users").document(opID).updateData(["name": newNameText])
            }
            else if (newBioText != originalBioText) //Only one has changed --> bio changed
            {
                firestore.collection("users").document(opID).updateData(["bio": newBioText])
            }
            
            if (newAvatar != originalAvatar) //Image upload
            {
                let avatarUUID = UUID().uuidString
                let uploadRef = Storage.storage().reference(withPath: "avatars/\(avatarUUID)")
                guard let imageData = selfProfilePicture.image?.jpegData(compressionQuality: 0.75) else
                { return }
                let uploadMetadata = StorageMetadata.init()
                uploadMetadata.contentType = "image/jpeg"
                uploadRef.putData(imageData, metadata: uploadMetadata) { (downloadMetadata, error) in
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                        return
                    }
                    print("Put complete, got: \(String(describing: downloadMetadata))")
                }
                firestore.collection("users").document(opID).updateData(["avatarID": avatarUUID])
            }
            //No else condition, as nothing happens if nothing has changed
            //This might get more complicated if/when I add profile pictures :'(
        }
        else
        {
            //Change to editing mode
            editingMode = true
            self.title = "Edit Profile"
            editButton.image = UIImage(systemName: "checkmark")
            selfName.isUserInteractionEnabled = true
            selfBio.isUserInteractionEnabled = true
            selfProfilePicture.isUserInteractionEnabled = true
            
            //Get original values of name and bio
            originalNameText = selfName.text!
            originalBioText = selfBio.text!
            originalAvatar = selfProfilePicture.image!
        }
    }
    
    @objc func tappedAvatar(_ sender: UITapGestureRecognizer)
    {
        avatarPicker.sourceType = .photoLibrary
        avatarPicker.delegate = self
        avatarPicker.allowsEditing = true
        present(avatarPicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageValue = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage
        {
            selfProfilePicture.image = imageValue
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
