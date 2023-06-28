//
//  Friend.swift
//  ios-habit-app
//
//  Created by Soodles . on 28/5/2023.
//

import UIKit

/**
 A class that represents a `Friend` object.
 */
class Friend: NSObject, Codable {
    // The ID number of the associated friend
    var id: String?
    // The email of the associated friend
    var email: String?
    // The name of the associated friend
    var name: String?
}
