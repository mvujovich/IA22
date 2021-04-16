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
    
    func setUpElements() {
        //Hide error label
        errorLabel.alpha = 0
        
        //More to come (when I work on the UI)
    }

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
                    self.goToHome()
                }
            }
        }
    }
    
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
