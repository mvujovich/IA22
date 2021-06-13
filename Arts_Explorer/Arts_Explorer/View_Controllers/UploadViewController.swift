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
    
    @IBOutlet weak var uploadButton: UIButton!
        
    @IBOutlet weak var artButton: UIButton!
    
    @IBOutlet weak var dramaButton: UIButton!
    
    @IBOutlet weak var filmButton: UIButton!
    
    @IBOutlet weak var musicButton: UIButton!
    
    var chosenCategories: Array<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
        // Do any additional setup after loading the view.
    }
    
    func setUpElements() {
        uploadButton.layer.cornerRadius = 5
        imageHolder.image = UIImage(named: "placeholder-post")
        imageHolder.contentMode = UIView.ContentMode.scaleAspectFill
        //Add more later
    }
    
    //MARK: - Upload post
    
    @IBAction func uploadPressed(_ sender: Any) {
        
        //Validate fields
        let error = validateFields()
        
        if error != nil {
            //If there is an error:
            createAlert(title: "Error", message: error!)
            //Exclamation point to force unwrap
        }
        else {
            let titleText: String = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let descriptionText: String = descriptionTextView.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let postUUID = UUID().uuidString
            var mediaID: String = ""
            if (imageHolder.image != UIImage(named: "placeholder-post"))
            {
                uploadImage(id: postUUID)
                mediaID = postUUID
            }
            let firestore = Firestore.firestore()
            let opID = Auth.auth().currentUser!.uid as String
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
                                    "approved": false,
                                    "categories": self.chosenCategories,
                                    "mediaID": mediaID,
                                    "title": titleText,
                                    "description": descriptionText,
                                    "time": Timestamp(date: Date())
                                ]) { (error) in
                                    if error != nil { //User object not saved to Firebase
                                        self.createAlert(title: "Error", message: "Post could not be added.")
                                    }
                                    else {
                                        self.createAlert(title: "Success!", message: "Post added successfully.")
                                        self.clearFieldsAndInfo()
                                    }
                                }
                } else {
                    self.createAlert(title: "Error", message: Constants.unknownUserError)
                }
            } //End larger async
        }
    }
    
    //MARK: - Validation
    
    func validateFields() -> String? { //Method returns optional String
        
        let titleText: String = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let descriptionText: String = descriptionTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        //Check all fields are filled in
        if (titleText == "") && (descriptionText == "") && (imageHolder.image == UIImage(named: "placeholder-post"))
        {
            return Constants.allFieldsEmptyError
        }
        
        else if (chosenCategories.isEmpty)
        {
            return Constants.noCategoryError
        }
        
        return nil
        
    }

    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func clearFieldsAndInfo()
    {
        titleTextField.text = ""
        descriptionTextView.text = ""
        imageHolder.image = UIImage(named: "placeholder-post")
        chosenCategories.removeAll()
        turnButtonOffVisually(buttonToTurnOff: artButton)
        turnButtonOffVisually(buttonToTurnOff: dramaButton)
        turnButtonOffVisually(buttonToTurnOff: filmButton)
        turnButtonOffVisually(buttonToTurnOff: musicButton)
    }
    
    //MARK: - Media
    
    @IBAction func pressedClearMedia(_ sender: Any) {
        imageHolder.image = UIImage(named: "placeholder-post")
        imageHolder.contentMode = UIView.ContentMode.scaleAspectFill
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
            imageHolder.contentMode = UIView.ContentMode.scaleAspectFit
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
                self.createAlert(title: "Error", message: "Error uploading image: \(error.localizedDescription)")
                return
            }
            //No need to notify user of success
        }
    }
    
    @IBAction func artPressed(_ sender: Any)
    {
        changeButton(button: artButton)
    }
    
    @IBAction func dramaPressed(_ sender: Any)
    {
        changeButton(button: dramaButton)
    }
    
    
    @IBAction func filmPressed(_ sender: Any)
    {
        changeButton(button: filmButton)
    }
    
    @IBAction func musicPressed(_ sender: Any)
    {
        changeButton(button: musicButton)
    }
    
    func changeButton(button: UIButton)
    {
        button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        
        if (button.isSelected) //Going from selected --> not selected
        {
            turnButtonOffVisually(buttonToTurnOff: button)
            while let index = chosenCategories.firstIndex(of: (button.currentTitle?.lowercased())!) {
                chosenCategories.remove(at: index)
            }
        }
        else //Going from not selected --> selected
        {
            turnButtonOnVisually(buttonToTurnOn: button)
            chosenCategories.append((button.currentTitle?.lowercased())!)
        }
    }
    
    func turnButtonOffVisually(buttonToTurnOff: UIButton)
    {
        buttonToTurnOff.backgroundColor = UIColor.systemGray5
        buttonToTurnOff.setTitleColor(UIColor.link, for: .normal)
        buttonToTurnOff.isSelected = false
    }
    
    func turnButtonOnVisually(buttonToTurnOn: UIButton)
    {
        buttonToTurnOn.backgroundColor = UIColor.systemGray2
        buttonToTurnOn.setTitleColor(UIColor.white, for: .normal)
        buttonToTurnOn.isSelected = true
    }
}

