//
//  FirebaseController.swift
//  ios-habit-app
//
//  Created by Soodles . on 7/5/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

// Private variables used for the Firebase Controller
private let EMAIL_KEY = "USER_EMAIL"
private let PASSWORD_KEY = "USER_PASSWORd"

/**
 The `FirebaseController` class provides a convenient interface for interacting with the Firebase backend.

 This class handles user authentication, database access, and other Firebase-related operations.
 */
class FirebaseController: NSObject, DatabaseProtocol {
    // The authorisation controller.
    var authController: Auth
    // The firestore database
    var database: Firestore
    //  Database listeners
    var listeners = MulticastDelegate<DatabaseListener>()
    
    // The reference to the user collection
    var usersRef: CollectionReference?
    // The current user that is signed in.
    var currentUser: FirebaseAuth.User?
    // The current user's Firestore document ID
    var currentUserDocumentID: String?
    // User defaults object.
    var userDefaults: UserDefaults?
    
    // List of habits
    var habitList: [Habit]
    // List of labels
    var labelList: [String]
    // List of friends
    var friendList: [Friend]
    // List of friend requests
    var friendRequests: [Friend]
    // List of friend activities
    var friendActivity: [String]
    // current user name
    var currentUserName: String?
    // current user email address.
    var currentUserEmail: String?
    
    /**
     Initialises a FirebaseController class.
     */
    override init() {
        // Configuring firebase app
        FirebaseApp.configure()
        self.authController = Auth.auth()
        self.database = Firestore.firestore()
        
        // Setting up variables for the database.
        self.habitList = [Habit]()
        self.labelList = [String]()
        self.friendList = [Friend]()
        self.friendRequests = [Friend]()
        self.friendActivity = [String]()
        self.usersRef = database.collection("users")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        userDefaults = appDelegate?.userDefaults
        
        super.init()
        
        // If user is signed in we sign them in, if not we exit the function.
        guard let  email = userDefaults?.string(forKey: EMAIL_KEY), let password = userDefaults?.string(forKey: PASSWORD_KEY) else{
            return
        }
        Task {
            await self.signInUser(email: email, password: password)
        }
    }
    
    
    func getFriendByEmail(email: String) async -> Friend?{
        // If the reference to the user collection does not exist then return nil
        guard let usersRef else {
            return nil
        }
        do {
            // Get find document that belongs to friend
            let friend = Friend()
            let snapshot = try await usersRef.whereField("email", isEqualTo: email).getDocuments()
            if !snapshot.documents.isEmpty {
                let friendID = snapshot.documents.first?.documentID
                friend.id = friendID
                friend.email = snapshot.documents.first?.data()["email"] as? String
                friend.name = snapshot.documents.first?.data()["name"] as? String
                return friend
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func createUser(name: String, email: String, password: String) async -> Bool {
        do {
            // Create a new user with the auth controller.
            let authDataResult = try await authController.createUser(withEmail: email, password: password)
            let user = User()
            user.auth_id = authDataResult.user.uid
            user.name = name
            user.habitList = [Habit]()
            user.email = authDataResult.user.email
            if let userRef = try usersRef?.addDocument(from: user){
                user.id = userRef.documentID
            }
            return true
        } catch {
            return false
        }
    }
    
    /**
     Checks whether a user is already a friend of the user.
     
     - Parameter newFriend: The new friend to check.
     */
    func alreadyFriend(newFriend: Friend) -> Bool{
        // Loops through friend list and compared each of the IDs
        for friend in friendList {
            if newFriend.id == friend.id {
                return true
            }
        }
        return false
    }
    
    func sendRequest(friend: Friend) async -> Bool? {
        // If current user document, users collection reference and current user email do not exist then return nil.
        guard let currentUserDocumentID, let usersRef, let currentUserEmail else {
            return nil
        }
        // If the friend ID is the current user or friend is already a friend return nil
        if friend.id == currentUserDocumentID || alreadyFriend(newFriend: friend) {
            return nil
        }
        do {
            // Get friend document ID and and send request.
            if let friendID = friend.id{
                let friendRef = usersRef.document(friendID)
                let currentUser = Friend()
                currentUser.id = currentUserDocumentID
                currentUser.email = currentUserEmail
                currentUser.name = currentUserName
                // Encoding current user's data.
                let myData = try Firestore.Encoder().encode(currentUser)
                // Add friend requests to friend's friend requests list.
                try await friendRef.updateData([
                    "friendRequests": FieldValue.arrayUnion([myData])
                ])
            }
            return true
        } catch {
            return false
        }
    }
    
    func declineRequest(friend: Friend) async -> Bool? {
        guard let currentUserDocumentID, let usersRef else {
            return nil
        }
        do {
            // Get document ID of user and
            let userRef = usersRef.document(currentUserDocumentID)
            let friendData = try! Firestore.Encoder().encode(friend)
            // Remove friend request from user's friend requests.
            try await userRef.updateData(["friendRequests": FieldValue.arrayRemove([friendData])])
            return true
        } catch {
            return false
        }
    }
    
    func addFriend(friend: Friend) async -> Bool?{
        guard let currentUserDocumentID, let usersRef, let currentUserEmail else {
            return nil
        }
        do {
            // Encode friend data
            let friendData = try Firestore.Encoder().encode(friend)
            
            // Get current user reference document, remove associated friend request and add to friend list.
            let userRef = usersRef.document(currentUserDocumentID)
            try await userRef.updateData(["friendRequests": FieldValue.arrayRemove([friendData])])
            try await userRef.updateData(["friendList": FieldValue.arrayUnion([friendData])])
            if let friendID = friend.id{
                let friendRef = usersRef.document(friendID)
                let currentUser = Friend()
                currentUser.id = currentUserDocumentID
                currentUser.email = currentUserEmail
                currentUser.name = currentUserName
                // Encoding current user's friend data
                let myData = try Firestore.Encoder().encode(currentUser)
                // Updating friend's friend list with current users data.
                try await friendRef.updateData(["friendList": FieldValue.arrayUnion([myData])])
            }
            return true
        } catch {
            return false
        }
    }
    
    func removeFriend(friend: Friend) async -> Bool? {
        guard let currentUserDocumentID, let usersRef else {
            return nil
        }
        do {
            // Removes friend from friend list
            let userRef = usersRef.document(currentUserDocumentID)
            let friendData = try! Firestore.Encoder().encode(friend)
            try await userRef.updateData(["friendList": FieldValue.arrayRemove([friendData])])
            // Removes current user from friend's friend list
            if let friendID = friend.id {
                let friendRef = usersRef.document(friendID)
                let currentUser = Friend()
                currentUser.email = currentUserEmail
                currentUser.name = currentUserName
                currentUser.id = currentUserDocumentID
                // Encoding current user's friend data.
                let myData = try! Firestore.Encoder().encode(currentUser)
                // Remove current user from friend's friend list.
                try await friendRef.updateData([
                    "friendList": FieldValue.arrayRemove([myData])
                ])
            }
            return true
        } catch {
            return false
        }
    }
    
    func signInUser(email: String, password: String) async -> Bool {
        do {
            // Attempt to sign in user with provided email and password
            let authDataResult = try await self.authController.signIn(withEmail: email, password: password)
            currentUser = authDataResult.user
            // Set up friend, label and habit listener
            Task {
                await setupFriendListener()
                await setUpLabelListener()
                await setUpHabitsListener()
            }
            // Set up user defaults for email and password.
            if let userDefaults {
                userDefaults.set(email, forKey: EMAIL_KEY)
                userDefaults.set(password, forKey: PASSWORD_KEY)
            }
            return true
        }
        // Catch any errors and return false.
        catch {
            return false
        }
    }
    
    
    
    func signOutUser() {
        do {
            // Set all user values to nil
            currentUser = nil
            currentUserDocumentID = nil
            habitList = []
            labelList = []
            friendList = []
            friendActivity = []
            friendRequests = []
            currentUserName = nil
            currentUserEmail = nil
            // Sign out user
            try authController.signOut()
            // Remove user default keys
            if let userDefaults {
                userDefaults.removeObject(forKey: EMAIL_KEY)
                userDefaults.removeObject(forKey: PASSWORD_KEY)
            }
            // Notify user database listeners
            listeners.invoke{(listener) in
                listener.onUserChange(change: .update)
            }
        }
        // Catch error and return
        catch {
            return
        }
    }
    
    func addListener(listener: DatabaseListener) {
        // Adds the database listener to listeners variable.
        listeners.addDelegate(listener)
        
        // Notify habit listeners
        if listener.listenerType == .habits || listener.listenerType == .all {
            listener.onHabitsChange(change: .update, habitList: habitList)
        }
        // Notify labels listeners
        if listener.listenerType == .labels || listener.listenerType == .all {
            listener.onLabelChange(change: .update, labelList: labelList)
        }
        // Notify friend listeners
        if listener.listenerType == .friends || listener.listenerType == .all {
            listener.onFriendsChange(
                change: .update,
                friendList: friendList,
                friendActivity: friendActivity,
                friendRequest: friendRequests
            )
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        // Remove listener
        listeners.removeDelegate(listener)
    }
    
    func notifyFriends(completionDate: String, habitName: String){
        guard let currentUserDocumentID ,let usersRef, let currentUserName  else {
            return
        }
        // Construct activity message with current user name and habit name.
        let message = "\(currentUserName) completed \(habitName) on \(completionDate)"
        
        // Notify all friends
        for friend in friendList {
            if let friendID = friend.id {
                let friendRef = usersRef.document(friendID)
                friendRef.updateData(
                    ["friendActivity": FieldValue.arrayUnion([message])]
                )
            }
            
        }
        // Adding message to user's activity
        let myMessage = "You completed \(habitName) on \(completionDate)"
        let userRef = usersRef.document(currentUserDocumentID)
        userRef.updateData(
            ["friendActivity": FieldValue.arrayUnion([myMessage])]
        )
    }
    
    func addHabit(habit: Habit) -> Bool? {
        guard let currentUserDocumentID else {
            return nil
        }
        // Adds habit to user's habit list
        if let userRef = usersRef?.document(currentUserDocumentID){
            // Encode new habit
            let habitData = try! Firestore.Encoder().encode(habit)
            // Update habitList field of document
            userRef.updateData(
                ["habitList": FieldValue.arrayUnion([habitData])]
            )
            return true
        } else {
            // Returns false if users collection is not initialised.
            return false
        }
    }
    
    func deleteHabit(habit: Habit) -> Bool? {
        guard let currentUserDocumentID else {
            return nil
        }
        // Removes habit from user's habit list
        if let userRef = usersRef?.document(currentUserDocumentID){
            let habitData = try! Firestore.Encoder().encode(habit)
            userRef.updateData(
                ["habitList":FieldValue.arrayRemove([habitData])]
            )
            return true
        } else {
            return false
        }
    }
    
    func updateHabits(habits: [Habit]) -> Bool? {
        guard let currentUserDocumentID else {
            return nil
        }
        // Updates all habits in habit list
        var habitDataArray = [Any]()
        if let userRef = usersRef?.document(currentUserDocumentID){
            // Loop through all habits, encode and append to habitDataArray.
            for habit in habits{
                let habitData = try! Firestore.Encoder().encode(habit)
                habitDataArray.append(habitData)
            }
            // Update habitList field in user's document
            userRef.updateData(
                ["habitList": habitDataArray]
            )
            return true
        } else {
            return false
        }
    }
    
    func addLabel(newLabel: String) -> Bool? {
        guard let currentUserDocumentID else {
            return nil
        }
        // Adding labels to user's labels.
        if let userRef = usersRef?.document(currentUserDocumentID){
            userRef.updateData(
                ["labelList": FieldValue.arrayUnion([newLabel])]
            )
            return true
        } else {
            return false
        }
    }
    
    func removeLabel(label: String) -> Bool? {
        guard let currentUserDocumentID else {
            return nil
        }
        // Getting user's document ID
        if let userRef = usersRef?.document(currentUserDocumentID){
            // Remove labels
            userRef.updateData(
                ["labelList": FieldValue.arrayRemove([label])]
            )
            return true
        } else {
            return false
        }
    }
    
    func setUpLabelListener() async {
        guard let usersRef, let currentUser = currentUser?.uid else {
            return
        }
        // Adding snapshot listener
        usersRef.whereField("auth_id", isEqualTo: currentUser).addSnapshotListener{ (querySnapshot, error) in
            // if there are no documents that match the auth_id then return
            guard let querySnapshot, let labelsSnapshot = querySnapshot.documents.first else {
                return
            }
            // Set the userDocumentID variable and parse snapshot
            let userDocumentID = labelsSnapshot.documentID as String
            self.currentUserDocumentID = userDocumentID
            self.parseLabelsSnapshot(snapshot: labelsSnapshot)
        }
    }
    
    func parseLabelsSnapshot(snapshot: QueryDocumentSnapshot){
        // Resets label list
        labelList = []
        
        // Parses the snapshot list and gets the list of labels.
        if let labels = snapshot.data()["labelList"] as? [String]{
            for label in labels {
                labelList.append(label)
            }
        }
        // Notify label listeners
        listeners.invoke{(listener) in
            if listener.listenerType == .labels || listener.listenerType == .all {
                listener.onLabelChange(change: .update, labelList: labelList)
            }
        }
    }
    
    func setupFriendListener() async {
        guard let usersRef, let currentUser = currentUser?.uid else {
            return
        }
        
        // Adding a snapshot listener.
        usersRef.whereField("auth_id", isEqualTo: currentUser).addSnapshotListener{(querySnapshot, error) in
            guard let querySnapshot, let friendsSnapshot = querySnapshot.documents.first else {
                return
            }
            
            // Set up the userDocumentID variable and parse snapshot.
            let userDocumentID = friendsSnapshot.documentID as String
            self.currentUserDocumentID = userDocumentID
            self.parseFriendsSnapshot(snapshot: friendsSnapshot)
        }
    }
    
    func parseFriendsSnapshot(snapshot: QueryDocumentSnapshot){
        // Resets all variables
        friendActivity = []
        friendList = []
        friendRequests = []
        
        // Parse the snapshot and gets the activities
        if let activities = snapshot.data()["friendActivity"] as? [String] {
            // Loop through activities and append to friend activity
            for activity in activities {
                friendActivity.append(activity)
            }
        }
        
        // Parse the snapshot and gets list of friends and stores it in friend list variable.
        if let friends = snapshot.data()["friendList"] as? (any Sequence) {
            // Loop through sequence and append to friend list
            for friend in friends {
                let friendData = try! Firestore.Decoder().decode(Friend.self, from: friend)
                friendList.append(friendData)
            }
        }
        
        // Parses the snapshot and gets the list of friend requests and stores it into the friend request variable.
        if let requests = snapshot.data()["friendRequests"] as? (any Sequence){
            // Loop through friend requests and append to friend requests
            for req in requests {
                let friendData = try! Firestore.Decoder().decode(Friend.self, from: req)
                friendRequests.append(friendData)
            }
        }
        if let userName = snapshot.data()["name"] as? String {
            currentUserName = userName
        }
        if let userEmail = snapshot.data()["email"] as? String {
            currentUserEmail = userEmail
        }
        // Update friend listeners of new friend list, friend activity and friend request.
        listeners.invoke{ (listener) in
            if listener.listenerType == .friends || listener.listenerType == .all {
                listener.onFriendsChange(change: .update, friendList: friendList, friendActivity: friendActivity, friendRequest: friendRequests)
            }
            if listener.listenerType == .user || listener.listenerType == .all {
                listener.onUserChange(change: .update)
            }
        }
    }
    
    func setUpHabitsListener() async{
        guard let usersRef, let currentUser = currentUser?.uid else {
            return
        }
        // Add snapshot listener.
        usersRef.whereField("auth_id", isEqualTo: currentUser).addSnapshotListener{(querySnapshot, error) in
            guard let querySnapshot, let habitSnapshot = querySnapshot.documents.first else {
                return
            }
            // Parse snapshot
            let userDocumentID = habitSnapshot.documentID as String
            self.currentUserDocumentID = userDocumentID
            self.parseHabitsSnapshot(snapshot: habitSnapshot)
        }
    }
    
    func parseHabitsSnapshot(snapshot: QueryDocumentSnapshot){
        // Resetting habit list variable
        habitList = []
        
        //  Gets "habitList" variable from snapshot
        if let habits = snapshot.data()["habitList"] as? (any Sequence){
            // Loop through habitList
            for habit in habits {
                let habitData = try! Firestore.Decoder().decode(Habit.self, from: habit)
                // Append to habit list
                habitList.append(habitData)
            }
        }
        // Update habit listeners with new habit list.
        listeners.invoke{ (listener) in
            if listener.listenerType == .habits || listener.listenerType == .all {
                listener.onHabitsChange(change: .update, habitList: habitList)
            }
        }
    }
    
}
