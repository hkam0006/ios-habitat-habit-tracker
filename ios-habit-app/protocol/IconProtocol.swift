//
//  IconProtocol.swift
//  ios-habit-app
//
//  Created by Soodles . on 23/4/2023.
//

import Foundation

/**
 Protocol that defines methods that need to be implemented for classes that inherit the `IconDelegate` class.
 */
protocol IconDelegate {
    // Method for updating the delegate's icon
    func updateIcon(_ icon: String)
    
    // Represents the icon currently selected
    var icon: String? {get set}
    
    // Boolean variable that represents if user has selected an icon.
    var iconChosen: Bool {get set}
    
    // Sets the save button to enable if conditions are met.
    func toggleSaveButton()
}
