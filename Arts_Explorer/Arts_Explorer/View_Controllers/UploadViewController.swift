//
//  UploadViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 15/4/2021.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
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
            
            //All fields have been validated; now force-unwrapped
            let titleText: String = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let descriptionText: String = descriptionTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let selectedItemInt: Int = categorySelector.selectedSegmentIndex
            let postUUID = UUID().uuidString
            
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
            
            let firestore = Firestore.firestore()
            let commentArray = [String]()
            //Do an array for categories later... fix it!
        
            firestore.collection("posts").addDocument(data:
                        [   //Data saved in Dictionary
                            "id": postUUID,
                            "op": "figure_out_later",
                            "approved": false,
                            "comments": commentArray,
                            "category": selectedCategory,
                            "mediaID": "figure_out_later",
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
                    }
    }
    
    func validateFields() -> String? { //Method returns optional String
        
        let titleText: String = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let descriptionText: String = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        //Check all fields are filled in
        if titleText == "" && descriptionText == "" //Fix this to be no media OR title OR desc
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
}
 
 /*
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 */
