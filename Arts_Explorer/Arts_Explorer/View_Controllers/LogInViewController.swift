//
//  LogInViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 15/4/2021.
//

import UIKit
import FirebaseAuth
import Firebase

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    ///This function initializes elements of the UI.
    func setUpElements() {
        //Hide error label
        errorLabel.alpha = 0
    }

    ///This function uses Firebase Authentication to try and log the user in.
    @IBAction func logInPressed(_ sender: Any) {
        let error = validateFields()
        
        if error != nil {
            //If there is an error:
            showError(message: error!) //Exclamation point to force unwrap
        }
        else {
            let passwordText: String = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let emailText: String = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().signIn(withEmail: emailText, password: passwordText) { (result, error) in
                
                if error != nil {
                    let errorMessage = error!.localizedDescription
                    self.showError(message: errorMessage)
                }
                else {
                    //Upon success, send user to home screen
                    self.goToHome()
                }
            }
        }
    }
    
    ///This function checks fields to see if the user has entered text correctly.
    func validateFields() -> String? { //Method returns optional String
        
        let passwordText: String = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let emailText: String = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        //Check all fields are filled in
        if  emailText == "" || passwordText == ""
        {
            return "Please fill in all fields."
        }
        
        return nil
    }
    
    ///This function handles the initial segue to the HomeViewController.
    func goToHome() {
        let tabViewController =
        storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeBarController) as? UITabBarController
        
        view.window?.rootViewController = tabViewController //set Home bar controller to root VC
        view.window?.makeKeyAndVisible()
    }
    
    ///This function displays errors to the user where necessary.
    func showError(message: String) {
        errorLabel.text = message
        errorLabel.alpha = 1 //Make error text visible
    }
    
}
