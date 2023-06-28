//
//  ProfileViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 18/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
// Properties
private let SEGUE_SIGNIN = "signInSegue"
private let SEGUE_ACKNOWLEDGEMENT = "acknowledgementSegue"

/**
 View controller for user signing in and out. View controller also contains about section which contains acknowledgements.
 */
class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DatabaseListener {
    // Database listener type
    var listenerType = ListenerType.user
    // Buttons
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var nameDisplayLabel: UILabel!
    // Database protocol
    var databaseController: DatabaseProtocol?
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var acknowledgementTableView: UITableView!
    var indicator = UIActivityIndicatorView()
    
    // Set up view controller on load
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = UIColor.label
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.layer.cornerRadius = 5
        // Add indicator to view
        self.view.addSubview(indicator)
        // Setting constraints
        NSLayoutConstraint.activate([
            // center horizontally
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Get database from app delegate
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        signOutButton.tintColor = UIColor.systemRed
        
        indicator.startAnimating()
        // Add tableview delegate and data source.
        handleButtonVisibility()
        acknowledgementTableView.delegate = self
        acknowledgementTableView.dataSource = self
        acknowledgementTableView.backgroundColor = UIColor.systemBackground
        acknowledgementTableView.isScrollEnabled = false
        indicator.stopAnimating()
    }
    
    /**
     Handle button visibility depending if the user is signed in or not.
     */
    func handleButtonVisibility(){
        if let _ = databaseController?.currentUser, let userName = databaseController?.currentUserName {
            signInButton.isHidden = true
            signUpButton.isHidden = true
            signOutButton.isHidden = false
            DispatchQueue.main.async {
                self.nameDisplayLabel.text = "Welcome back, \(userName)"
            }
            initialsLabel.text = getInitials(name: userName)
        } else {
            signInButton.isHidden = false
            signUpButton.isHidden = false
            signOutButton.isHidden = true
            DispatchQueue.main.async {
                self.nameDisplayLabel.text = "You are not signed in"
                self.initialsLabel.text = "?"
            }
            
        }
    }
    
    // Handle when sign out button is pressed.
    @IBAction func signOutButton(_ sender: Any) {
        databaseController?.signOutUser()
        handleButtonVisibility()
    }
    
    // Get initials of the user.
    func getInitials(name: String) -> String{
        if !name.isEmpty {
            var result = String(name[name.startIndex])
            var previousLetter = name[name.startIndex]
            for letter in name{
                if previousLetter == " " && letter != " "{
                    result.append(letter)
                }
                previousLetter = letter
            }
            return result
        }
        return "?"
    }
    
    //MARK: - Database Listener delegate methods
    
    func onHabitsChange(change: DatabaseChange, habitList: [Habit]) {
        // nothing
    }
    
    func onLabelChange(change: DatabaseChange, labelList: [String]) {
        // nothing
    }
    
    func onFriendsChange(change: DatabaseChange, friendList: [Friend], friendActivity: [String], friendRequest: [Friend]) {
        // nothing
    }
    
    func onUserChange(change: DatabaseChange) {
        handleButtonVisibility()
    }
    
    // MARK: - Table View delegate methods
    
    // Table view only has one row.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Styling cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "acknowledgementCell")!
        cell.textLabel?.text = "About"
        cell.backgroundColor = UIColor(named: "AccentColour")
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    // Handle when about button is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: SEGUE_ACKNOWLEDGEMENT, sender: self)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    // Add listener
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        databaseController?.addListener(listener: self)
    }
    
    // Remove listener when view disappears
    override func viewWillDisappear(_ animated: Bool) {
        databaseController?.removeListener(listener: self)
    }
}
