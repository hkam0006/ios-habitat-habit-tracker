//
//  UIViewController+DisplayMessage.swift
//  ios-habit-app
//
//  Created by Soodles . on 7/5/2023.
//

import UIKit
 
extension UIViewController {
    /**
     Displays message alert
     */
    func displayMessage(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
    }
}
