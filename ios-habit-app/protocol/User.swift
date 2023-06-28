//
//  User.swift
//  ios-habit-app
//
//  Created by Soodles . on 6/5/2023.
//

import UIKit
import FirebaseFirestoreSwift
/**
 A class that represents a user
 */
class User: NSObject, Codable {
    // The unique identifier of the user
    @DocumentID var id: String?
    
    // The authentication ID associated with the user.
    var auth_id: String?
    
    // The name associated with user
    var name: String?
    
    // The list of habits associated with the user
    var habitList: [Habit] = []
    
    // The initial list of labels available for habits.
    var labelList: [String] = ["Morning","Afternoon","Night", "After work", "Before bed"]
    
    // The email associated with the user
    var email: String?
    
    // The list of friends associated with user
    var friendList: [Friend] = []
    
    // A list of friend activity associated with user
    var friendActivity: [String] = []
    
    // A list of friend requests associated with the user.
    var friendRequests: [Friend] = []
}
