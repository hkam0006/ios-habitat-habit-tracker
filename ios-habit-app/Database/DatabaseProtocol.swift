//
//  DatabaseProtocol.swift
//  ios-habit-app
//
//  Created by Soodles . on 6/5/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

/**
 A enumeration that represents database changes.
 */
enum DatabaseChange {
    case add
    case remove
    case update
}

/**
 A enumeration that represents different database listener types.
 */
enum ListenerType {
    case user
    case habits
    case labels
    case friends
    case all
}

/**
 The `DatabaseListener` protocol defines methods that a listener object should implement to receive updates from a database.

 A class that conforms to this protocol can register as a listener with a DatabaseController object. It will then receive notifications about changes in the database, such as changes in habits, labels, friends, or user information.

 - Note: Conforming classes should typically be weakly referenced to avoid retain cycles.

 - Remark: The databaseController property should be set by the DatabaseController object when registering the listener.

 - Remark: The listenerType property can be used to identify the type of listener, allowing the DatabaseController to dispatch appropriate updates.

 - See Also: `DatabaseController`
 */
protocol DatabaseListener: AnyObject {
    /**
     The database controller that this listener is associated with.
     */
    var databaseController: DatabaseProtocol? { get set }
    /**
     The type of listener
     */
    var listenerType: ListenerType {get set}
    
    /**
     Called when changes occur in the list of habits in the database.

     - Parameters:
        - change: The type of change that occurred (e.g., added, modified, deleted).
        - habitList: The updated list of habits in the database.
     */
    func onHabitsChange(change: DatabaseChange, habitList: [Habit])
    
    /**
     Called when changes occur in the list of labels in the database.

     - Parameters:
        - change: The type of change that occurred (e.g., added, modified, deleted).
        - labelList: The updated list of labels in the database.
     */
    func onLabelChange(change: DatabaseChange, labelList: [String])
    
    /**
     Called when changes occur in the list of friends in the database.

     - Parameters:
        - change: The type of change that occurred (e.g., added, modified, deleted).
        - friendList: The updated list of friends in the database.
        - friendActivity: The updated list of friend activities.
        - friendRequest: The updated list of friend requests.
     */
    func onFriendsChange(change: DatabaseChange, friendList: [Friend], friendActivity: [String], friendRequest: [Friend])
    
    /**
     Called when changes occur in the user information in the database.
     
     - Parameter change: The type of change that occurred (e.g., added, modified, deleted).
     */
    func onUserChange(change: DatabaseChange)
}

/**
    The `DatabaseProtocol` protocol defines methods for interacting with a database, including user management, data manipulation, and listener management.

    An object conforming to this protocol serves as the interface between the application and the underlying database system. It provides methods for creating and managing user accounts, as well as manipulating data such as habits and labels. Additionally, it allows adding and removing listeners to receive updates from the database.

    - Note: Conforming classes should typically be weakly referenced to avoid retain cycles.

    - Remark: The currentUser property represents the currently authenticated user, while the currentUserName property holds the name of the current user.

    - SeeAlso: `DatabaseListener`

*/
protocol DatabaseProtocol: AnyObject {
    /**
     The currently signed-in user
     */
    var currentUser: FirebaseAuth.User? {get set}
    /**
     The name of the current user.
     */
    var currentUserName: String? {get set}
    
    // MARK: - User creation and management.
    
    /**
     Creates a new user with the specified name, email, and password.
     
     - Parameters:
        - name: The name of the user
        - email: The email address of the user.
        - password: The password for the user.
     - Returns: A boolean value indicating whether the user creation was successful.
     */
    func createUser(name: String, email: String, password: String) async -> Bool
    
    /**
     Signs in the user with the specified email and password.
     
     - Parameters:
        - email: The account email associated with user's account
        - password: The account password associated with user's account
     - Returns: A boolean value indicating whether the user was signed-in successfully.
     */
    func signInUser(email: String, password: String) async -> Bool
    
    /**
     Signs out currently signed-in user.
     */
    func signOutUser()
    
    // MARK: Database methods
    
    /**
     Adds a listener to receive updates and notifications about changes in the database.
          
      - Parameter listener: The listener to be added.
     */
    func addListener(listener: DatabaseListener)
    
    /**
     Removes a previously added listener.
          
      - Parameter listener: The listener to be removed.
     */
    func removeListener(listener: DatabaseListener)
    
    // MARK: Data Manipulation
    
    /**
     Adds a new habit to the database.
     
     - Parameters habit: The habit to be added.
     - Returns: A boolean value indicating whether the habit creation was successfull.
     */
    func addHabit(habit: Habit) -> Bool?
    
    /**
     Deletes a habit from the database.
     
     - Parameters habit: The habit to be removed from the database
     - Returns: A boolean value indicating whether the habit deletion was successful.
     */
    func deleteHabit(habit: Habit) -> Bool?
    
    /**
     Updates the list of habits in the database.
     
     - Parameter habits: The updated list of habits.
     - Returns: A boolean a value indicating whether the habit list updated successfully.
     */
    func updateHabits(habits: [Habit]) -> Bool?
    
    /**
     Adds a new label to the database.
     
     - Parameter newLabel: The new label to be added.
     - Returns: A boolean value indicating whether the label was successfully added.
     */
    func addLabel(newLabel: String) -> Bool?
    
    /**
     Removes a label from the database.
     
     - Parameter label: The label to be removed.
     - Returns: A boolean value indicating whether the label was successfully removed.
     */
    func removeLabel(label: String) -> Bool?
    
    /**
     Retrieves a friend from the database based on their email address.
     
     - Parameter email: The email address of the friend.
     - Returns: A `Friend` object representing the friend if found, or `nil` if not found.
     */
    func getFriendByEmail(email: String) async -> Friend?
    
    /**
     Sends a friend request to the specified friend.
     
     - Parameter friend: THe friend to send the request to.
     - Returns: A boolean value indicating whether the request was successfully sent.
     */
    func sendRequest(friend: Friend) async -> Bool?
    
    /**
     Removes a friend from the user's friend list.
     
     - Parameters friend: The friend to be removed.
     - Returns: A boolean value indicating whether the friend was successfully removed.
     */
    func removeFriend(friend: Friend) async -> Bool?
    
    /**
     Notifies friends about the completion of a habit.
     
     - Parameters:
        - completionDate: The completion date of the habit
        - habitName: The name of the habit.
     */
    func notifyFriends(completionDate: String, habitName: String)
    
    /**
     Adds a friend to the user's friend list.
     
     - Parameter friend: The friend to be added.
     - Returns: A boolean value indicating whether the friend was successfully added.
     */
    func addFriend(friend: Friend) async -> Bool?
    
    /**
     Declines a friend request from the specified friend.
     
     - Parameter friend: The fried whose request is being declined.
     - Returns: A boolean value indicating whether the request was successfully declined.
     */
    func declineRequest(friend: Friend) async -> Bool?
}
