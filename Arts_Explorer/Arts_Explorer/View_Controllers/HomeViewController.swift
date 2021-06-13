//
//  HomeViewController.swift
//  Arts_Explorer
//
//  Created by Mirjana Aleksandra Qi Vujovich on 15/4/2021.
//

import UIKit
import Firebase
import SideMenu

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MenuControllerDelegate {
    
    @IBOutlet weak var postListTableView: UITableView!
    
    var leftMenu: SideMenuNavigationController?
    
    //MARK: - Loading posts
    
    var postsToShow = [AEPost]()
    
    var opID: String = ""
    var opName: String = ""
    var postID: String = ""
    
    var currentCategory: String = ""
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            postListTableView.refreshControl = refreshControl
        } else {
            postListTableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(reloadPosts(_:)), for: .valueChanged)

        postListTableView.register(PostTableViewCell.nib(), forCellReuseIdentifier: PostTableViewCell.identifier)
        postListTableView.rowHeight = UITableView.automaticDimension
        postListTableView.delegate = self
        postListTableView.dataSource = self
        
        //TODO: Add support for posts without images
        //postListTableView.estimatedRowHeight = 300.0
        
        //Setting up left side menu
        let menu = MenuListController()
        menu.delegate = self
        leftMenu = SideMenuNavigationController(rootViewController: menu)
        leftMenu?.leftSide = true
        leftMenu?.setNavigationBarHidden(true, animated: false)
        
        SideMenuManager.default.leftMenuNavigationController = leftMenu
        SideMenuManager.default.addPanGestureToPresent(toView: self.view)
        
        loadPosts()
    }
    
    //MARK: - Load all posts
    
    func loadPosts() {
        let firestore = Firestore.firestore()
        firestore.collection("posts").whereField("approved", isEqualTo: true).order(by: "time", descending: true).limit(to: 15).getDocuments()
        { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.postsToShow.removeAll()
                    self.postListTableView.reloadData()
                    for document in querySnapshot!.documents
                    {
                        let postID: String = document.get("id") as! String
                        let postOPID: String = document.get("opID") as! String
                        let postOPName: String = document.get("opName") as! String
                        //Do comments later
                        let postCategories: Array<String> = document.get("categories") as! Array<String>
                        let mediaID: String = document.get("mediaID") as! String
                        let postTitle: String = document.get("title") as! String
                        let postDescription: String = document.get("description") as! String
                        let postTime: Timestamp = document.get("time") as! Timestamp
                        let post: AEPost = AEPost(id: postID, opID: postOPID, opName: postOPName, approved: true, categories: postCategories, mediaID: mediaID, title: postTitle, description: postDescription, time: postTime)
                        self.postsToShow.append(post)
                        let indexPath = IndexPath(row: self.postsToShow.count-1, section: 0)
                        self.postListTableView.insertRows(at: [indexPath], with: .automatic)
                    }
                    if (self.postsToShow.isEmpty)
                    {
                        self.createAlert(title: "Error", message: "There are no posts here. Try somewhere else! :(")
                    }
                }
            }
        self.refreshControl.endRefreshing()
    }
    
    //MARK: - Load specific posts
    
    func loadSpecificPosts(categoryChosen: String)
    {
        let firestore = Firestore.firestore()
        
        firestore.collection("posts").whereField("approved", isEqualTo: true).whereField("categories", arrayContains: categoryChosen).order(by: "time", descending: true).limit(to: 15).getDocuments()
            { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.postsToShow.removeAll()
                    self.postListTableView.reloadData()
                    for document in querySnapshot!.documents {
                        let postID: String = document.get("id") as! String
                        let postOPID: String = document.get("opID") as! String
                        let postOPName: String = document.get("opName") as! String
                        //Do comments and categories (proper) and media ID later
                        let postCategories: Array<String> = document.get("categories") as! Array<String>
                        let mediaID: String = document.get("mediaID") as! String
                        let postTitle: String = document.get("title") as! String
                        let postDescription: String = document.get("description") as! String
                        let postTime: Timestamp = document.get("time") as! Timestamp
                        let post: AEPost = AEPost(id: postID, opID: postOPID, opName: postOPName, approved: true, categories: postCategories, mediaID: mediaID, title: postTitle, description: postDescription, time: postTime)
                        self.postsToShow.append(post)
                        let indexPath = IndexPath(row: self.postsToShow.count-1, section: 0)
                        self.postListTableView.insertRows(at: [indexPath], with: .automatic)
                        }
                    if (self.postsToShow.isEmpty)
                    {
                        self.createAlert(title: "Error", message: "There are no posts here. Try somewhere else! :(")
                    }
                    }
                }
        self.refreshControl.endRefreshing()
    }
    
    //MARK: - After choosing item
    
    func didSelectMenuItem(chosen: String)
    {
        leftMenu?.dismiss(animated: true, completion: nil)
        
        if (chosen == "moderation")
        {
            performSegue(withIdentifier: "showModerationFromHome", sender: self)
        }
        else if (chosen == "log out")
        {
            do
            {
                try Auth.auth().signOut()
            }
            catch let signOutError as NSError
            {
              print ("Error signing out: %@", signOutError)
            }
            if let storyboard = self.storyboard
            {
                let initialNC = storyboard.instantiateViewController(withIdentifier: "initialNavigationController") as! UINavigationController
                initialNC.modalPresentationStyle = .fullScreen
                self.present(initialNC, animated: false, completion: nil)
            }
        }
        else if (chosen == "home")
        {
            loadPosts()
        }
        else
        {
            loadSpecificPosts(categoryChosen: chosen)
            currentCategory = chosen
        }
        
    }
    
    
    @objc func reloadPosts(_ sender: Any) {
        if (currentCategory == "")
        {
            self.loadPosts()
        }
        else
        {
            self.loadSpecificPosts(categoryChosen: currentCategory)
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
        
        cell.callBackOnCommentButton = {
            self.prepareInfo(indexPath: indexPath)
            self.performSegue(withIdentifier: "showCommentsFromPost", sender: nil)
        }
        return cell
    }
    
    func prepareInfo(indexPath: IndexPath)
    {
        opID = postsToShow[indexPath.row].opID
        opName = postsToShow[indexPath.row].opName
        postID = postsToShow[indexPath.row].id
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
                    prepareInfo(indexPath: indexPath)
                    otherProfileViewController.otherUserID = opID
                    otherProfileViewController.otherUserName = opName
                }
        }
        
        if segue.identifier == "showCommentsFromPost"
        {
            let commentsViewController = segue.destination as! CommentsViewController
            commentsViewController.postID = postID
            commentsViewController.opName = opName
        }
    }
    
    //MARK: - Alert
    
    func createAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: {(action) in alert.dismiss(animated: true, completion: nil)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Side menu
    
    @IBAction func tappedMenu()
    {
        present(leftMenu!, animated: true)
    }
    
}

protocol MenuControllerDelegate {
    func didSelectMenuItem(chosen: String)
}

class MenuListController: UITableViewController //Class needed for inheritance stuff
{
    var menuListItems = [String]()
    
    var userIsMod: Bool = false
    let darkColor: UIColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
    //let highlightColor: UIColor = UIColor(red: 1, green: 0.4176320933, blue: 0.3837106635, alpha: 1) --> Red like the background of the launch screen
    
    public var delegate: MenuControllerDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let firestore = Firestore.firestore()
        let currentUserID = Auth.auth().currentUser!.uid as String
        self.tableView.backgroundColor = self.darkColor
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.menuItemIdentifier)
        
        let docRef = firestore.collection("users").document("\(currentUserID)")
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                self.userIsMod = document.get("mod") as! Bool
                if (self.userIsMod)
                {
                    self.menuListItems = ["Home", "Art", "Drama", "Film", "Music", "Moderation", "Log out"]
                    self.tableView.reloadData()
                }
                else
                {
                    self.menuListItems = ["Home", "Art", "Drama", "Film", "Music", "Log out"]
                    self.tableView.reloadData()
                }
                
            } else {
                print("Document does not exist")
            }
        }
        
    }
    
    //MARK: - Menu table actions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuListItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.menuItemIdentifier, for: indexPath)
        cell.textLabel?.text = menuListItems[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.backgroundColor = darkColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = menuListItems[indexPath.row]
        delegate?.didSelectMenuItem(chosen: selectedItem.lowercased())
        print(selectedItem)
    }

}
 
