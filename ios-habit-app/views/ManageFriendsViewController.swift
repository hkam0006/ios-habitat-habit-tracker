//
//  ManageFriendsViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 28/5/2023.
//

import UIKit

private let CELL_FRIEND = "friendCell"
private let CELL_REQUEST = "requestCell"
private let SECTION_REQUESTS = 0
private let SECTION_FRIENDS = 1

/**
 View controller for managing friends such as adding and removing friends.
 */
class ManageFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    var listenerType = ListenerType.friends
    
    var databaseController: DatabaseProtocol?
    var friendList: [Friend] = []
    var pendingRequests : [Friend] = []
    @IBOutlet weak var friendListTableView: UITableView!
    @IBOutlet weak var addFriendButton: UIBarButtonItem!
    
    var indicator = UIActivityIndicatorView()
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up loading indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = UIColor.label
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            // center horizontally
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        // Get database controller from app delegate.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            databaseController = appDelegate.databaseController
        }
        // Set up table view delegate and data source.
        friendListTableView.delegate = self
        friendListTableView.dataSource = self
        if databaseController?.currentUser == nil {
            addFriendButton.isEnabled = false
        } else {
            addFriendButton.isEnabled = true
        }
    }
    
    /**
     Handles the action when the "Add Friend" button is pressed.
     */
    @IBAction func addFriendButtonPressed(_ sender: Any) {
        // Create an alert controller to prompt for friend's email
        let alertController = UIAlertController(title: "Send Friend Request", message: nil, preferredStyle: .alert)
        // Add a text field to the alert controller.
        alertController.addTextField {(textField) in
            textField.placeholder = "Enter friend's email"
        }
        
        // Create the "Add" action
        let addAction = UIAlertAction(title: "Add", style: .default){ [weak alertController] _ in
            // Start loading animation
            self.indicator.startAnimating()
            // check if text fields and datavase controller exist
            guard let textFields = alertController?.textFields, let databaseController = self.databaseController else {
                return
            }
            // get the entered friend's email
            if let newFriend = textFields[0].text, newFriend.isValidEmail() {
                Task {
                    // Retrieve the friend from the database by email
                    if let friend = await databaseController.getFriendByEmail(email: newFriend){
                        if let requestSent = await databaseController.sendRequest(friend: friend){
                            // Send a friend requst.
                            if requestSent {
                                // Friend request sent successfully
                                self.indicator.stopAnimating()
                                let successfulAlert = UIAlertController(title: "Friend request sent!", message: nil, preferredStyle: .alert)
                                successfulAlert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                                self.present(successfulAlert, animated: true, completion: nil)
                            } else {
                                // Friend not found, display an alert.
                                self.indicator.stopAnimating()
                                let unsuccessfulAlert = UIAlertController(title: "Friend not found. Try again", message: nil, preferredStyle: .alert)
                                unsuccessfulAlert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                                self.present(unsuccessfulAlert, animated: true, completion: nil)
                            }
                        }
                    } else {
                        // Friend not found, display an elert.
                        self.indicator.stopAnimating()
                        let friendNotFoundAlert = UIAlertController(title: "Email does not exist", message: "Please enter a valid email address", preferredStyle: .alert)
                        friendNotFoundAlert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                        self.present(friendNotFoundAlert, animated: true, completion: nil)
                    }
                }
            } else {
                // Invalid email entered, display an alert.
                self.indicator.stopAnimating()
                let invalidEmailAlert = UIAlertController(title: "Invalid Email Entered", message: "Please enter a valid email address", preferredStyle: .alert)
                invalidEmailAlert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                self.present(invalidEmailAlert, animated: true, completion: nil)
            }
        }
        
        // Create an Cancel action
        let cancelActon = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        // Add actions to the alert controller.
        alertController.addAction(cancelActon)
        alertController.addAction(addAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table Cell Delegation Methods
    
    // Handle when decline friend request is tapped.
    func declineFriendRequest(friend: Friend){
        guard let databaseController else {
            return
        }
        Task {
            await databaseController.declineRequest(friend: friend)
        }
    }
    
    // Handle when accept friend request is tapped.
    func acceptFriendRequest(friend: Friend){
        guard let databaseController else {
            return
        }
        Task {
            await databaseController.addFriend(friend: friend)
        }
    }
    
    // MARK: - Database Listener methods
    
    func onHabitsChange(change: DatabaseChange, habitList: [Habit]) {
        // nothing
    }
    
    func onLabelChange(change: DatabaseChange, labelList: [String]) {
        // nothing
    }
    
    func onUserChange(change: DatabaseChange) {
        // nothing
    }
    
    // Update friend list when notified by the database.
    func onFriendsChange(change: DatabaseChange, friendList: [Friend], friendActivity: [String], friendRequest: [Friend]) {
        self.friendList = friendList
        self.pendingRequests = friendRequest
        friendListTableView.reloadData()
    }
    
    // MARK: - Table View data source
    
    // Number of rows in table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_FRIENDS {
            return self.friendList.count
        } else {
            return self.pendingRequests.count
        }
    }
    
    // Configure table view cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_REQUESTS {
            // COnfiguring friend request cells.
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REQUEST) as! FriendRequestTableViewCell
            cell.selectionStyle = .none
            cell.userNameLabel.text = pendingRequests[indexPath.row].name
            cell.emailLabel.text = pendingRequests[indexPath.row].email
            cell.friend = pendingRequests[indexPath.row]
            cell.declineButton.tintColor = UIColor.systemRed
            cell.delegate = self
            return cell
        } else {
            // Configuring friend cells.
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_FRIEND) as! FriendTableViewCell
            if let name = friendList[indexPath.row].name, let email = friendList[indexPath.row].email {
                cell.emailLabel.text = email
                cell.nameLabel.text = name
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    // There are two sections in the table view, friend requests and friend list.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // Handling editting of cells,
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let databaseController else {
            return
        }
        if editingStyle == .delete && indexPath.section == SECTION_FRIENDS {
            // Only allow deleting of friends
            let selectedFriend = friendList[indexPath.row]
            Task {
                // Removing friend
                let removedFriend = await databaseController.removeFriend(friend: selectedFriend)
                if removedFriend != nil {
                    let alertController = UIAlertController(title: "Friend Removed Successfully", message: nil, preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
                    alertController.addAction(dismissAction)
                    self.present(alertController, animated: true)
                }
            }
        }
    }
    
    // Setting titles for sections
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_FRIENDS {
            // Title of friend sections
            return "Friends"
        }
        if section == SECTION_REQUESTS && !pendingRequests.isEmpty{
            // Title for friend requests section, if there is pending request list is not empty.
            return "Friend Requests"
        }
        return nil
    }
    
    // Setting title for section footers
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == SECTION_FRIENDS {
            // Footer title for friend section
            return "\(friendList.count) friend(s)"
        }
        if section == SECTION_REQUESTS && !pendingRequests.isEmpty {
            // Footer title for friend requests section if pending requests list is not empty.
            return "\(pendingRequests.count) pending requests"
        }
        return nil
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // Handle when view controller appears in the view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adding listener to database on load
        databaseController?.addListener(listener: self)
        // Handling button enable and disable
        if databaseController?.currentUser == nil {
            // if user is not signed in
            addFriendButton.isEnabled = false
        } else {
            // if user is signed in.
            addFriendButton.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove listener when view controller disappears.
        databaseController?.removeListener(listener: self)
    }
}
