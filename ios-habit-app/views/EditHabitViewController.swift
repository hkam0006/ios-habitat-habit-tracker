//
//  EditHabitViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 15/5/2023.
//

import UIKit

private let SEGUE_EDIT_REPEAT = "editRepeatSegue"
private let SEGUE_EDIT_METRIC = "editMetricSegue"
private let SEGUE_EDIT_LABELS = "editLabelsSegue"
private let SEGUE_EDIT_REMINDERS = "editRemindersSegue"
private let SEGUE_EDIT_ICON = "editIconSegue"

/**
 View controller for editting habits.
 */
class EditHabitViewController: UIViewController, HabitModification, RepeatDelegate, LabelDelegate, MetricDelegate, IconDelegate, ReminderDelegate {
    // The habit that is being customised.
    var habit: Habit?
    // The database controller that will be updated when changes are made.
    var databaseController: DatabaseProtocol?
    // The habit repeat settings
    var currentRepeat: Repeat?
    // The habit reminders settings
    var currentReminderController: RemindersController?
    // The metric settings
    var currentMetric: Metric?
    // The labels settings
    var currentLabels: Labels?
    // The habit icon
    var icon: String?
    var iconChosen = true
    // The list of habits
    var habitList: [Habit]?
    
    // Outlets.
    @IBOutlet weak var habitIconButton: UIButton!
    @IBOutlet weak var habitColourPreview: UIView!
    @IBOutlet weak var habitNameInput: UITextField!
    @IBOutlet weak var habitDescriptionInput: UITextField!
    @IBOutlet weak var habitRepeatObject: UILabel!
    @IBOutlet weak var habitCategoriesLabel: UILabel!
    @IBOutlet weak var habitMetricLabel: UILabel!
    @IBOutlet weak var habitRemindersLabel: UILabel!
    @IBOutlet weak var habitMetricIcon: UIImageView!
    
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var tealButton: UIButton!
    @IBOutlet weak var indigoButton: UIButton!
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get database instance from app delegate.
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            databaseController = appDelegate.databaseController
        }
        // exit if habit settings are not provided.
        guard let habit, let labelSettings = habit.categories, let metricSettings = habit.metric, let repeatSettings = habit.repeatObject, let reminderSettings = habit.reminderController else {
            return
        }
        // Make a copy of the habit settings, original habit settings will not be overwritten unless explicitly saved by the user.
        currentLabels = labelSettings.copy()
        currentMetric = metricSettings.copy()
        currentRepeat = repeatSettings.copy()
        currentReminderController = reminderSettings.copy()
        
        // Update user interface according to provided habit settings
        setupInitialHabitInformation()
    }
    
    /**
     Function that handles reflects habit settings chosen by the user.
     
     - Note: If habit is not set up properly, exist without updating the user interface.
     */
    func setupInitialHabitInformation(){
        guard let habit else {
            return
        }
        habitColourPreview.backgroundColor = habit.getUIColour()
        if let icon = habit.icon {
            setupIcon(icon: icon, iconButton: habitIconButton)
        }
        habitNameInput.text = habit.name
        habitDescriptionInput.text = habit.habitDescription
        if let repeatObject = habit.repeatObject {
            setupRepeatTitle(repeatObject: repeatObject, repeatTitleLabel: habitRepeatObject)
        }
        if let metric = habit.metric {
            setupMetricTitle(metric: metric, metricLabel: habitMetricLabel, metricIcon: habitMetricIcon)
        }
        if let categories = habit.categories {
            setupLabelsTitle(categories: categories, categoriesLabel: habitCategoriesLabel)
        }
        if let reminders = currentReminderController {
            setupReminderTitle(reminder: reminders, reminderLabel: habitRemindersLabel)
        }
    }
    
    /**
     Handles interaction when delete button for the habit is tapped.
     
     This warns the user that once a habit is deleted, all related data will be deleted as well and cannot be retrieved. If user selects `Yes` it will remove the habit from the database.
     
     - Parameter sender: The button that trigerred the action.
     */
    @IBAction func deleteButtonPressed(_ sender: Any) {
        guard let habit, let databaseController else {
            return
        }
        // Creating a alert
        let alertController = UIAlertController(title: "Delete Habit", message: "All data will be lost. Are you sure you want to delete this habit?", preferredStyle: .alert)
        // Creating a yes/confirm action
        let yesAction = UIAlertAction(title: "Yes", style: .default) {_ in
            let _ = databaseController.deleteHabit(habit: habit)
            self.dismiss(animated: true)
        }
        // Creating a no action
        let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
        
        // Add actions to the alert.
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        
        // Present the alert controller.
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Handles when the colour button has been chosen.
     
     - Parameter sender: The button that triggered the action.
     */
    @IBAction func colourButtonChanged(_ sender: Any) {
        guard let buttonSender = sender as? UIButton else {
            return
        }
        switch buttonSender {
        case redButton:
            habitColourPreview.backgroundColor = UIColor.systemRed
        case orangeButton:
            habitColourPreview.backgroundColor = UIColor.systemOrange
        case yellowButton:
            habitColourPreview.backgroundColor = UIColor.systemYellow
        case greenButton:
            habitColourPreview.backgroundColor = UIColor.systemGreen
        case tealButton:
            habitColourPreview.backgroundColor = UIColor.systemTeal
        case indigoButton:
            habitColourPreview.backgroundColor = UIColor.systemIndigo
        default:
            print("default")
        }
    }
    
    /**
     This method saves the changes to the settings.
     
     - Parameter sender: The button that triggered the action.
     */
    @IBAction func saveChanges(_ sender: Any) {
        // Check if habit object exists
        guard let habit else {
            return
        }
        // Update habit properties
        habit.name = habitNameInput.text
        habit.setColor(colour: habitColourPreview.backgroundColor!)
        habit.categories = currentLabels
        habit.metric = currentMetric
        habit.repeatObject = currentRepeat
        habit.reminderController = currentReminderController
        
        // Checks if habit has an ID.
        if let habit_id = habit.id {
            let center = UNUserNotificationCenter.current()
            // Remove any previosly delivered notifications for the habit.
            center.removeDeliveredNotifications(withIdentifiers: ["\(habit_id)_reminder"])
            
            // Schedule notifications for each reminder in the controller.
            if let currentReminderController{
                for reminder in currentReminderController.allReminders {
                    let content = UNMutableNotificationContent()
                    content.title = "Habit Reminder: \(habit.name!)"
                    content.body = "Have you completed '\(habit.name!)' yet?"
                    var dateComponents = DateComponents()
                    dateComponents.hour = reminder.hour
                    dateComponents.minute = reminder.minute
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: "\(habit_id)_reminder", content: content, trigger: trigger)
                    center.add(request)
                }
            }
        }
        // Update the habit list associated with user.
        if let databaseController, let habitList {
            let _ = databaseController.updateHabits(habits: habitList)
        }
        
        // Pop the current view controller from the navigation stack
        navigationController?.popViewController(animated: true)
    }
    
    // Handle the dismissal of the view controller.
    @IBAction func undoChanges(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    // MARK: - Delegation Methods
    
    func updateRepeat() {
        guard let currentRepeat else {
            return
        }
        setupRepeatTitle(repeatObject: currentRepeat, repeatTitleLabel: habitRepeatObject)
    }
    
    func updateLabels() {
        guard let currentLabels else {
            return
        }
        setupLabelsTitle(categories: currentLabels, categoriesLabel: habitCategoriesLabel)
    }
    
    func updateMetric() {
        guard let currentMetric else {
            return
        }
        setupMetricTitle(
            metric: currentMetric,
            metricLabel: habitMetricLabel,
            metricIcon: habitMetricIcon
        )
    }
    
    func updateIcon(_ icon: String) {
        self.icon = icon
        setupIcon(icon: icon, iconButton: habitIconButton)
    }
    
    func toggleSaveButton() {
        // do nothing
    }
    
    func updateReminderControllerDelegate() {
        guard let currentReminderController else {
            return
        }
        setupReminderTitle(reminder: currentReminderController, reminderLabel: habitRemindersLabel)
    }

    
    // MARK: - Navigation
    
    // Prepare / setup destination view controllers.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Set up RepeatViewController
        if segue.identifier == SEGUE_EDIT_REPEAT {
            if let destination = segue.destination as? RepeatViewController{
                destination.repeatDelegate = self
                destination.repeatObject = currentRepeat
            }
        }
        // Set up LabelViewController
        if segue.identifier == SEGUE_EDIT_LABELS {
            if let destination = segue.destination as? LabelViewController {
                destination.delegate = self
                destination.currentLabels = currentLabels
            }
        }
        // Set up MetricViewController
        if segue.identifier == SEGUE_EDIT_METRIC {
            if let destination = segue.destination as? MetricViewController{
                destination.delegate = self
                destination.currentMetric = currentMetric
            }
        }
        // Set up IconCollectionViewController
        if segue.identifier == SEGUE_EDIT_ICON {
            if let destination = segue.destination as? IconCollectionViewController {
                destination.delegate = self
            }
        }
        // Set up SetRemindersViewController
        if segue.identifier == SEGUE_EDIT_REMINDERS {
            if let destination = segue.destination as? SetRemindersViewController {
                destination.delegate = self
                destination.remindersController = currentReminderController
            }
        }
    }
}
