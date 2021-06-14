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

    ///This function uses Firebase to create a new user using the entered data.
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
            
            Auth.auth().createUser(withEmail: emailText, password: passwordText) { (result, err) in
                    if err != nil {
                        self.showError(message: "There was an error creating the account.")
                    }
                    else {
                        
                        //Empty String Arrays
                        let savedPostArray = [String]()
                        
                        //Add document to Firebase
                        let firestore = Firestore.firestore()
                        firestore.collection("users").document(result!.user.uid).setData([
                            //Data saved in Dictionary
                            "id": result!.user.uid,
                            "name": nameText,
                            "mod": false,
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
    
    ///This function checks all fields to see if the user has entered text correctly.
    ///It returns a String describing the error if there is one, and nil if there is no error.
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
            return "Password should contain a letter, number and special character, and at least 8 characters."
        }
        
        if validateEmail(input: emailText) == false {
            return "Please enter a valid email."
        }
        
        return nil
    }
    
    ///This function checks to see if the password is secure enough by using regular expressions.
    func validatePassword(input: String) -> Bool {
        let passRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        //≥8 characters, incl. 1+ special characters, letters, and numbers
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passRegex)
        return passwordTest.evaluate(with: input)
    }
    
    ///This function checks to see if the email is valid by using regular expressions.
    func validateEmail(input: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        //≥8 characters, incl. 1+ special characters, letters, and numbers
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        if (validateSchoolEmail(inputString: input) == true)
        {
            return emailTest.evaluate(with: input)
        }
        return false
    }
    
    ///This function checks to see if the validated email is a CIS email.
    func validateSchoolEmail(inputString: String) -> Bool {
        let emailParts = inputString.components(separatedBy: "@")
        let emailSuffix = emailParts[1]
        let validSuffixes = ["cis.edu.hk", "alumni.cis.edu.hk", "student.cis.edu.hk"]
        if (validSuffixes.contains(emailSuffix))
        {
            return true
        }
        return false
    }
    
    ///This function handles the initial segue to the HomeViewController.
    func goToHome() {
        let tabViewController =
        storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeBarController) as? UITabBarController
        
        view.window?.rootViewController = tabViewController //set Home bar to root VC
        view.window?.makeKeyAndVisible()
    }
    
    ///This function displays errors to the user where necessary.
    func showError(message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1 //Make error text visible
    }

}
