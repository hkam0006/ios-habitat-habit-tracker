//
//  SignInViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 7/5/2023.
//

import UIKit

/**
 View controller for signing in.
 */
class SignInViewController: UIViewController, UITextFieldDelegate {
    // email and password text fields
    @IBOutlet weak var emailTextInput: UITextField!
    @IBOutlet weak var passwordTextInput: UITextField!
    // Activity indicator for loading
    var indicator = UIActivityIndicatorView()
    
    // Initial view controller set up
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up text field delegate
        emailTextInput.delegate = self
        passwordTextInput.delegate = self
        
        // Set up activity indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = UIColor.label
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            // center horizontally
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    /**
     Handles when the sign in button is tapped.
     
     - Parameter sender: The button that triggered the action.
     */
    @IBAction func signInButtonPressed(_ sender: Any) {
        // Animate the activity indicator.
        indicator.startAnimating()
        // Check if email and password inputs is not nil
        guard let email = emailTextInput.text, let password = passwordTextInput.text else {
            indicator.stopAnimating()
            return
        }
        // Connect to database controller
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let databaseController = appDelegate?.databaseController
        // Synchronous environment for asynchronous code
        Task {
            // Attemp to sign in user.
            if let signInSuccesfull = await databaseController?.signInUser(email: email, password: password) {
                indicator.stopAnimating()
                // Display message if sign in unsuccessful
                if !signInSuccesfull {
                    displayMessage(title: "Invalid Credentials provided", message: "Invalid email/password. Please try again")
                } else {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // MARK: - Text Field Delegate
    /**
     Informs the text  field delegate that the return button was pressed on the keyboard.
     
     - Parameter textField: The text field for which the return button was pressed.
     - Returns: A boolean value indicating whether the text field should process the return button press.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Overrides the default behaviour when touches are detected on the screen.

     - Parameters:
        - touches: A set of `UITouch` objects representing the touches that occurred.
        - event: The event that encapsulates the touches for handling multitouch interactions.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /**
     Handles when the cancel button is pressed.
     
     - Parameter sender: The button that triggered the action.
     */
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
}
