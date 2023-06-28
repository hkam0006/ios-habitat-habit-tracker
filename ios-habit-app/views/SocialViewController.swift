//
//  SocialViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 27/5/2023.
//

import UIKit

private let CELL_ACTIVITY = "activityCell"

/**
 View controller for viewing friend activity and managing friends.
 */
class SocialViewController: UIViewController, DatabaseListener, UITableViewDataSource, UITableViewDelegate {
    // Database listener
    var listenerType = ListenerType.friends
    var friendList: [Friend] = []
    var friendActivity: [String] = []
    @IBOutlet weak var manageFriendsButton: UIBarButtonItem!
    var databaseController: DatabaseProtocol?
    @IBOutlet weak var messageActivityTableView: UITableView!
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up table view delegate and data source
        messageActivityTableView.delegate = self
        messageActivityTableView.dataSource = self
        // Retrieving database controller.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            databaseController = appDelegate.databaseController
        }
        // Handle manage friends button
        if databaseController?.currentUser != nil {
            manageFriendsButton.isEnabled = true
        } else {
            manageFriendsButton.isEnabled = false
        }
    }
    
    
    // MARK: - Table View Data Source
    
    // Setting the number of rows in the table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendActivity.count
    }
    
    // Configure cell for table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ACTIVITY, for: indexPath) as! ActivityTableViewCell
        cell.activityMessage.text = friendActivity[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - Database Listener Methods
    
    func onHabitsChange(change: DatabaseChange, habitList: [Habit]) {
        // do nothing
    }
    
    func onLabelChange(change: DatabaseChange, labelList: [String]) {
        // do nothing
    }
    
    // Handle when friend activity changes
    func onFriendsChange(change: DatabaseChange, friendList: [Friend], friendActivity: [String], friendRequest: [Friend]) {
        // Reverse list to show most recent activity on the top.
        var reversedList = friendActivity
        reversedList.reverse()
        self.friendActivity = reversedList
        // Reload table view
        messageActivityTableView.reloadData()
    }
    
    func onUserChange(change: DatabaseChange) {
        // nothing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if databaseController?.currentUser != nil {
            manageFriendsButton.isEnabled = true
        } else {
            manageFriendsButton.isEnabled = false
        }
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
}
