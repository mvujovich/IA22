//
//  SignUpViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 15/4/2021.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements() {
        //Hide error label
        errorLabel.alpha = 0
        
        //More to come (when I work on the UI)
    }

    @IBAction func signUpPressed(_ sender: Any) {
        
        //Validate fields
        let error = validateFields()
        
        if error != nil {
            //If there is an error:
            showError(message: error!) //Exclamation point to force unwrap
        }
        else {
            
            //All fields have been validated; now force-unwrapped
            let nameText: String = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let passwordText: String = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailText: String = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let firestore = Firestore.firestore()
            Auth.auth().createUser(withEmail: emailText, password: passwordText) { (result, err) in
                    if err != nil {
                        self.showError(message: "There was an error creating the account.")
                    }
                    else {
                        
                        //Empty String Arrays
                        let postArray = [String]()
                        let savedPostArray = [String]()
                        
                        //Add document to Firebase
                        firestore.collection("users").addDocument(data:
                        [   //Data saved in Dictionary
                            "id": result!.user.uid,
                            "name": nameText,
                            "mod": false,
                            "posts": postArray,
                            "savedPosts": savedPostArray,
                            "avatarID": "",
                            "bio": ""
                        ]) { (error) in
                            if error != nil { //User object not saved to Firebase
                                self.showError(message: "User data could not be saved.")
                            }
                        }
                    }
                
                //Take user to Home screen
                self.goToHome()
            }
        }
    }
    
    func validateFields() -> String? { //Method returns optional String
        
        let passwordText: String = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let emailText: String = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        //Check all fields are filled in
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || emailText == "" || passwordText == ""
        {
            return "Please fill in all fields."
        }
        
        //Validate password, then email, fields
        if validatePassword(input: passwordText) == false {
            return "Please make sure your password contains at least 1 letter, 1 number and 1 special character, and is at least 8 characters long."
        }
        
        if validateEmail(input: emailText) == false {
            return "Please enter a valid email."
        }
        
        return nil
    }
    
    func validatePassword(input: String) -> Bool {
        let passRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        //≥8 characters, incl. 1+ special characters, letters, and numbers
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passRegex)
        return passwordTest.evaluate(with: input)
    }
    
    func validateEmail(input: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        //≥8 characters, incl. 1+ special characters, letters, and numbers
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: input)
    }
    
    func goToHome() {
        let tabViewController =
        storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeBarController) as? UITabBarController
        
        view.window?.rootViewController = tabViewController //set Home bar to root VC
        view.window?.makeKeyAndVisible()
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
