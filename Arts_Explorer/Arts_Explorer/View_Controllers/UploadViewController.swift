//
//  UploadViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 15/4/2021.
//

import UIKit
import Firebase
import FirebaseStorage

class UploadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: - Variables
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var imageHolder: UIImageView!
    var imagePickerType = UIImagePickerController()
    
    @IBOutlet weak var chooseButton: UIButton!
    
    @IBOutlet weak var categorySelector: UISegmentedControl!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        errorLabel.alpha = 0
        uploadButton.layer.cornerRadius = 5
        //Add more later
    }
    
    //MARK: - Upload post
    
    @IBAction func uploadPressed(_ sender: Any) {
        
        //Validate fields
        let error = validateFields()
        
        if error != nil {
            //If there is an error:
            showError(message: error!)
            self.errorLabel.textColor = UIColor.systemRed
            //Exclamation point to force unwrap
        }
        else {
            let titleText: String = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let descriptionText: String = descriptionTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let selectedItemInt: Int = categorySelector.selectedSegmentIndex
            let commentArray = [String]()
            
            var selectedCategory: String = "music"
            
            if selectedItemInt == 0 {
                selectedCategory = "art"
            }
            else if selectedItemInt == 1 {
                selectedCategory = "drama"
            }
            else if selectedItemInt == 2 {
                selectedCategory = "film"
            }
            
            //FIX THIS LATER ^
            
            let postUUID = UUID().uuidString
            var mediaID: String = ""
            if (imageHolder.image != nil)
            {
                uploadImage(id: postUUID)
                mediaID = postUUID
            }
            
            let firestore = Firestore.firestore()
            let opID = Auth.auth().currentUser!.uid as String
            print("user id is \(opID)")
            var opName: String = ""
            let docRef = firestore.collection("users").document(opID)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    opName = document.get("name") as! String
                    firestore.collection("posts").document(postUUID).setData(
                                [   //Data saved in Dictionary
                                    "id": postUUID,
                                    "opID": opID,
                                    "opName": opName,
                                    "approved": true, //MARK: - FIX 'APPROVED'
                                    "comments": commentArray,
                                    "category": selectedCategory,
                                    "mediaID": mediaID,
                                    "title": titleText,
                                    "description": descriptionText
                                ]) { (error) in
                                    if error != nil { //User object not saved to Firebase
                                        self.showError(message: "Post could not be added.")
                                        self.errorLabel.textColor = UIColor.systemRed
                                    }
                                    else {
                                        self.showError(message: "Post added successfully.")
                                        self.errorLabel.textColor = UIColor.systemGreen
                                    }
                                }
                } else {
                    self.showError(message: "User does not exist.")
                }
            } //End larger async
        }
    }
    
    //MARK: - Validation
    
    func validateFields() -> String? { //Method returns optional String
        
        let titleText: String = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let descriptionText: String = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        //Check all fields are filled in
        if titleText == "" && descriptionText == "" && imageHolder.image == nil //Fix this to be no media OR title OR desc
        {
            return "Please fill in at least one field."
        }
        
        //Category defaults to art; no need to check
        return nil
    }

    func showError(message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1 //Make error text visible
    }
    
    //MARK: - Media
    
    @IBAction func pressedChooseMedia(_ sender: Any) {
        imagePickerType.sourceType = .photoLibrary
        imagePickerType.delegate = self
        imagePickerType.allowsEditing = true
        present(imagePickerType, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageValue = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")]as? UIImage
        {
            imageHolder.image = imageValue
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(id: String)
    {
        let uploadRef = Storage.storage().reference(withPath: "posts/\(id)")
        guard let imageData = imageHolder.image?.jpegData(compressionQuality: 0.75) else
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
    }
}
 
 /*
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 */
