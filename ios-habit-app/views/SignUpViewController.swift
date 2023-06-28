//
//  SignUpViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 7/5/2023.
//

import UIKit

/**
 View controller for user sign up
 */
class SignUpViewController: UIViewController, UITextFieldDelegate{
    // Storyboard outlets.
    @IBOutlet weak var emailTextInput: UITextField!
    @IBOutlet weak var passwordTextInput: UITextField!
    @IBOutlet weak var retypePasswordTextInput: UITextField!
    @IBOutlet weak var nameTextInput: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    // Database controller
    weak var databaseController: DatabaseProtocol?
    // Loading Indicator
    var indicator = UIActivityIndicatorView()

    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up text field delegate.
        emailTextInput.delegate = self
        passwordTextInput.delegate = self
        retypePasswordTextInput.delegate = self
        nameTextInput.delegate = self
        
        // Set up loading indicator.
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = UIColor.label
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.layer.cornerRadius = 5
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            // center horizontally
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        // Retrieve database controller from App Delegate.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Setting up placeholders for text fields
        emailTextInput.placeholder = "Enter email"
        passwordTextInput.placeholder = "Enter password"
        retypePasswordTextInput.placeholder = "Retype password"
        nameTextInput.placeholder = "Enter name"
        // Initially the create account button is disabled.
        createAccountButton.isEnabled = false
    }
    
    /**
     Handle when the form has been changed
     
     - Parameter sender: The fields that triggered the action.
     */
    @IBAction func formDidChange(_ sender: Any) {
        guard let nameText = nameTextInput.text, !nameText.isEmpty else {
            createAccountButton.isEnabled = false
            return
        }
        guard let emailText = emailTextInput.text, emailText.isValidEmail() else {
            createAccountButton.isEnabled = false
            return
        }
        guard isPasswordValidated() else {
            createAccountButton.isEnabled = false
            return
        }
        createAccountButton.isEnabled = true
    }
    
    /**
     Checks if password and password validation are the same.
     */
    func isPasswordValidated() -> Bool {
        guard let newPassword = passwordTextInput.text, !newPassword.isEmpty else {
            return false
        }
        guard let passwordValidation = retypePasswordTextInput.text, !passwordValidation.isEmpty else {
            return false
        }
        if newPassword == passwordValidation {
            return true
        } else {
            return false
        }
    }
    
    /**
     Creates an user account
     */
    @IBAction func createAccount(_ sender: Any) {
        // Starts loading animation
        indicator.startAnimating()
        // checks if email, password and name exist
        guard let email = emailTextInput.text,let name = nameTextInput.text, let password = passwordTextInput.text else {
            return
        }
        // Sychronous environment for asychronous environment.
        Task {
            // Create user
            guard let userCreated = await databaseController?.createUser(name:name, email: email, password: password) else {
                return
            }
            // Stop loading animation when user is created.
            indicator.stopAnimating()
            // if user created
            if userCreated {
                let alertController = UIAlertController(title: "New account created!!", message: "Your new account has been created", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .default){_ in
                    self.dismiss(animated: true)
                }
                alertController.addAction(dismissAction)
                present(alertController, animated: true, completion: nil)
                return
            } else {
                let alertController = UIAlertController(title: "Failed to create account!", message: "Account already exists. Try another email", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
                alertController.addAction(dismissAction)
                present(alertController, animated: true, completion: nil)
                return
            }
            
        }
    }
    
    /**
     Handle when cancel button is tapped.
     */
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /**
     Handle when return button is pressed on the keyboard.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Resigns first responder when user touches out of the text field.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension String {
    // checks if a string is a valid email.
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        if !predicate.evaluate(with: self){
            return false
        }
        return true
    }
}
