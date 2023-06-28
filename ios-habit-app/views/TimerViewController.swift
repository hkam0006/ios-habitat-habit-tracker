//
//  TimerViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 30/4/2023.
//

import UIKit
import SwiftUI

/**
 A view controller that handles tracking time-based habits.
 */
class TimerViewController: UIViewController {
    // The habit that is being timed
    var habit: Habit?
    // The habit table view cell that triggered the segue to this view controller.
    var cell: HabitTableViewCell?
    // The selected date used to update progress.
    var selectedDate: Date?
    // Delegate
    var delegate: AllHabitsViewController?
    // Habit name label
    @IBOutlet weak var habitNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     Performs a segue to the SwiftTimer view controller. This segue action is triggered when this view controller is loaded.
     
     - Parameter coder: The NSCoder object used for encoding and decoding the view controller.
     - Returns: An instance of UIViewController if the necessary data is available, otherwise nil.
     */
    @IBSegueAction func swiftTimerSegue(_ coder: NSCoder) -> UIViewController? {
        // Return nil if neccessary date is not set up properly
        guard let habit,let colourTheme = habit.getUIColour(), let selectedDate, let totalTimeFloat = habit.getTotalTime() else {
            return nil
        }
        // Get total time as an integer
        let totalTimeInt = Int(totalTimeFloat)
        // Get time float as an integer
        let timeFloat = habit.getProgressOnDate(date: selectedDate) * totalTimeFloat
        let timeInt = Int(timeFloat)
        // Integrating SwiftUI view with a UIKit view hierarchy.
        return UIHostingController(
            coder: coder,
            rootView: TimerSwiftUIView(habit: habit, theme: colourTheme.cgColor, elapsedTime: timeInt, totalTime: totalTimeInt, date: selectedDate)
        )
    }
    
    // Handle when dismiss button is pressed.
    @IBAction func dismissActionPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    
    
    
    // MARK: - Navigation
    // Handle updating the UI for the cell that triggered the display of this view controller.
    override func viewDidDisappear(_ animated: Bool) {
        guard let cell else {
            return
        }
        cell.updateProgressBar()
    }
}
