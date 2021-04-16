//
//  UploadViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 15/4/2021.
//

import UIKit
import Firebase

class UploadViewController: UIViewController {
    
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var imageHolder: UIImageView!
    
    @IBOutlet weak var categorySelecter: UISegmentedControl!
    
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
            showError(message: error!) //Exclamation point to force unwrap
        }
        else {
            
            //All fields have been validated; now force-unwrapped
            let titleText: String = titleTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let descriptionText: String = descriptionTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let selectedItemInt: Int = categorySelecter.selectedSegmentIndex
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
                            }
                        }
                    }
    }
    
    func validateFields() -> String? { //Method returns optional String
        
        let titleText: String = titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let descriptionText: String = descriptionTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        //Check all fields are filled in
        if titleText == "" && descriptionText == "" //Fix this to be no media OR title OR desc
        {
            return "Please fill in all fields."
        }
        
        //Category defaults to art; no need to check
        
        return nil
    }

    func showError(message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1 //Make error text visible
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
