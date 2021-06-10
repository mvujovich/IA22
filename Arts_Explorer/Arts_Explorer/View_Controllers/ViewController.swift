//
//  ViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 14/4/2021.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var logInButton: UIButton!
    
    override func viewDidLoad() {
        if FirebaseApp.app() == nil
        {
                FirebaseApp.configure()
        }
        if Auth.auth().currentUser != nil
        {
            if let storyboard = self.storyboard
            {
                let homeVC = storyboard.instantiateViewController(withIdentifier: "mainTabBarViewController") as! UITabBarController
                homeVC.modalPresentationStyle = .fullScreen
                self.present(homeVC, animated: false, completion: nil)
            }
        }
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // get screen size object.
    }
    
    @IBAction func signUpPressed(_ sender: Any?) {
        
    }
    
    @IBAction func logInPressed(_ sender: Any?) {
        
    }
}
