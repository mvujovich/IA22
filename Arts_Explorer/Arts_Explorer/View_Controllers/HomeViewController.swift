//
//  HomeViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 15/4/2021.
//

import UIKit
import Firebase
import SideMenu

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var postListTableView: UITableView!
    
    var menu: SideMenuNavigationController?
    
    //MARK: - Loading posts
    
    var postsToShow = [AEPost]()
    
    var opID: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postListTableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        postListTableView.rowHeight = UITableView.automaticDimension
        postListTableView.delegate = self
        postListTableView.dataSource = self
        
        //TODO: Add support for posts without images
        //postListTableView.estimatedRowHeight = 300.0
        
        //Setting up left side menu
        menu = SideMenuNavigationController(rootViewController: MenuListController())
        menu?.leftSide = true
        SideMenuManager.default.leftMenuNavigationController = menu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        
        loadPosts()
        // Do any additional setup after loading the view.
    }
    
    func loadPosts() {
        
        let firestore = Firestore.firestore()
        firestore.collection("posts").whereField("approved", isEqualTo: true)
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
                        self.postListTableView.insertRows(at: [indexPath], with: .automatic)
                            
                        }
                    }
                }
        }
    
    //MARK: - Table View specifics
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsToShow.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //postListTableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showProfileFromPost", sender: indexPath)
    }
    
//  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = postListTableView.dequeueReusableCell(withIdentifier:               PostTableViewCell.identifier) as! PostTableViewCell
//        cell.configure(with: postsToShow[indexPath.row])
//        let textViewHeight = cell.descriptionText.frame.size.height
//        return textViewHeight+129+view.frame.size.width }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = postListTableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as! PostTableViewCell
        cell.configure(with: postsToShow[indexPath.row])
        return cell
    }
    
    //MARK: - Side menu
    
    @IBAction func tappedMenu()
    {
        present(menu!, animated: true)
    }
    
    //MARK: - Segue to profile
    //Preparation before navigating to new views
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //let indexPath = postListTableView.indexPathForSelectedRow!
        // Get the Row of the Index Path and set as index
        // Get in touch with the new VC
        
        //let cell = (sender as! PostTableViewCell)
        //opID = cell.hiddenOPIDText.text!
        // Pass on the data to the Detail ViewController by setting its indexPathRow value
        
        if segue.identifier == "showProfileFromPost" {
                if let indexPath = self.postListTableView.indexPathForSelectedRow  {
                    let otherProfileViewController = segue.destination as! OtherProfileViewController
                    opID = postsToShow[indexPath.row].opID
                    let opName = postsToShow[indexPath.row].opName
                    otherProfileViewController.otherUserID = opID
                    otherProfileViewController.otherUserName = opName
                }
        
        }
    }
}

class MenuListController: UITableViewController //Class needed for inheritance stuff
{
    var menuListItems = ["Home", "Art", "Drama", "Film", "Theatre", "Log out"]
    
    var userIsMod: Bool = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let firestore = Firestore.firestore()
        let opID = Auth.auth().currentUser!.uid as String
        
        let docRef = firestore.collection("users").document("\(opID)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.userIsMod = document.get("mod") as! Bool
                self.menuListItems.insert("Moderation", at: 4)
            } else {
                print("Document does not exist")
            }
        }
        print("count of mli is \(menuListItems.count)")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.menuItemIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuListItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.menuItemIdentifier, for: indexPath)
        cell.textLabel?.text = menuListItems[indexPath.row]
        return cell
    }

}
 
