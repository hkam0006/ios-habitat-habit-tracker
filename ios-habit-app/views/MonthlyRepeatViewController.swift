//
//  MonthlyRepeatViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 21/4/2023.
//

import UIKit

/**
 View controller for customising a monthly repetition habit
 */
class MonthlyRepeatViewController: UIViewController, UITextFieldDelegate {
    // Repeat delegate.
    var delegate: RepeatPageDelegate?
    var repeatObject: Repeat?
    @IBOutlet weak var numberOfTimesInput: UITextField!
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        numberOfTimesInput.delegate = self
        guard let repeatObject = repeatObject, let monthlyTimes = repeatObject.monthlyTimes else {
            return
        }
        numberOfTimesInput.text = String(monthlyTimes)
    }
    
    /**
     Handles when text input changes
     
     - Parameter sender: The text field that triggered the action.
     */
    @IBAction func textDidChange(_ sender: Any) {
        guard let delegate = delegate, let repeatObject = repeatObject, let textInput = numberOfTimesInput.text else {
            return
        }
        let numberInput = textInput.filter("0123456789.".contains)
        numberOfTimesInput.text = numberInput
        guard let integer = Int(numberInput) else {
            repeatObject.monthlyTimes = 1
            delegate.updateRepeat(repeatObject)
            return
        }
        repeatObject.monthlyTimes = integer
        delegate.updateRepeat(repeatObject)
    }
    
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
}
