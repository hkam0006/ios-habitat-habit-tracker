//
//  NewHabitViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 18/4/2023.
//

import UIKit

// Private properties
private let SEGUE_REPEAT = "repeatSegue"
private let SEGUE_METRIC = "metricSegue"
private let SEGUE_LABEL = "labelSegue"
private let SEGUE_ICON = "iconSegue"
private let SEGUE_REMINDERS = "reminderSegue"
private let SEGUE_HEALTHKIT = "healthKitSegue"
private let CELL_REPEAT = "repeatCell"
private let CELL_CATEGORY = "categoryCell"
private let CELL_METRIC = "metricCell"
private let CELL_NOTIFICATIONS = "notificationsCell"

/**
 View controller for adding new habits.
 */
class NewHabitViewController: UIViewController, HabitModification, RepeatDelegate, LabelDelegate, MetricDelegate, IconDelegate, ReminderDelegate, UITextFieldDelegate{
    // Storyboard outlets
    @IBOutlet weak var colourPreviewView: UIView!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var indigoButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var tealButton: UIButton!
    @IBOutlet weak var metricIcon: UIImageView!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var habitNameTextInput: UITextField!
    @IBOutlet weak var iconButton: UIButton!
    @IBOutlet weak var repeatTitleLabel: UILabel!
    @IBOutlet weak var namedLabelTitleLabel: UILabel!
    @IBOutlet weak var metricTitleLabel: UILabel!
    @IBOutlet weak var nameDescriptionBackground: UIView!
    @IBOutlet weak var customisationBackground: UIView!
    @IBOutlet weak var notificationsLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // MARK: - Properties
    // Current Repeat Settings
    var currentRepeat: Repeat?
    // Current label settings
    var currentLabels: Labels?
    // Current metric settings
    var currentMetric: Metric?
    // Current selected icon
    var icon: String?
    // Current reminder settings
    var currentReminderController: RemindersController?
    // Selected habit start date.
    var startDate: Date?
    // Boolean variables to keep track of if user has selected icon and colour.
    var colourChosen = false
    var iconChosen = false
    
    // The new habit delegate.
    var delegate: NewHabitDelegate?
    
    // databaseController.
    weak var databaseController: DatabaseProtocol?
    
    // Setting up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get database controller instance from UIApplication
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Setting text field delegate as self.
        descriptionTextField.delegate = self
        habitNameTextInput.delegate = self
        
        
        // Setting up properties of the view controller
        startDate = delegate?.selectedDate
        
        // Creating default habit settings.
        currentRepeat = createDefaultRepeatObject()
        currentLabels = createDefaultLabelsObject()
        currentMetric = createDefaultMetricObject()
        currentReminderController = RemindersController()
        
        // Setting up labels according to default objects.
        guard let currentMetric, let currentRepeat, let currentLabels else {
            return
        }
        setupMetricTitle(metric: currentMetric, metricLabel: metricTitleLabel, metricIcon: metricIcon)
        setupRepeatTitle(repeatObject: currentRepeat, repeatTitleLabel: repeatTitleLabel)
        setupLabelsTitle(categories: currentLabels, categoriesLabel: namedLabelTitleLabel)
    }
    
    /**
    Handles the color change of buttons.

    - Parameter sender: The button that triggered the action.
    */
    @IBAction func handleColourChange(_ sender: Any) {
        guard let buttonSender = sender as? UIButton else {
            return
        }
        // Sets thhe colourChosen flag to true
        colourChosen = true
        // Enable or disable the save button based on the colour selection
        toggleSaveButton()
        switch buttonSender {
        case redButton:
            colourPreviewView.backgroundColor = UIColor.systemRed
        case orangeButton:
            colourPreviewView.backgroundColor = UIColor.systemOrange
        case yellowButton:
            colourPreviewView.backgroundColor = UIColor.systemYellow
        case greenButton:
            colourPreviewView.backgroundColor = UIColor.systemGreen
        case tealButton:
            colourPreviewView.backgroundColor = UIColor.systemTeal
        case indigoButton:
            colourPreviewView.backgroundColor = UIColor.systemIndigo
        default:
            print("default")
        }
    }
    
    /**
     Handles the action when "Cancel" button is pressed.
     
     This method is called when "Cancel" button is tapped. It dimsmiss the current view controller modally, effectivelly discarding any unsaved changes.
     
     - Parameter sender: The button that triggered the action
     */
    @IBAction func discardChangesButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /**
     Handles the action when habit name has changed
     
     This method is called everytime the editting on habit name is changed.
     
     - Parameter sender: The text input that triggered the action.
     */
    @IBAction func habitNameChanged(_ sender: Any) {
        toggleSaveButton()
    }
    
    /**
     Handles the enabling/disabling of the save button.
     */
    func toggleSaveButton(){
        guard let name = habitNameTextInput.text, let currentMetric, let currentRepeat  else {
            return
        }
        var validRepeat = true
        var validMetric = true
        if let monthlyTimes = currentRepeat.monthlyTimes, currentRepeat.type == .monthly && monthlyTimes <= 0 {
            validRepeat = false
        }
        if currentRepeat.type == .daily && currentRepeat.daysArray.count == 0 {
            validRepeat = false
        }
        if let totalTime = currentMetric.totalTime , currentMetric.type == .timed && totalTime <= 0 {
            validMetric = false
        }
        if let totalFreq = currentMetric.totalFrequency, currentMetric.type == .frequency && totalFreq <= 0{
            validMetric = false
        }
        
        // Set the metric title label colours
        if validMetric {
            metricTitleLabel.textColor = UIColor.label
        } else {
            metricTitleLabel.textColor = UIColor.systemRed
        }
        // Set the repeat title label colours
        if validRepeat {
            repeatTitleLabel.textColor = UIColor.label
        } else {
            repeatTitleLabel.textColor = UIColor.systemRed
        }
        
        // Enable button if name is not empty and when colour and icon is chosen.
        let canSave = !name.isEmpty && colourChosen && iconChosen && validMetric && validRepeat
        if !canSave {
            saveButton.isEnabled = false
        } else {
            // Enable button if all condition above were met
            saveButton.isEnabled = true
        }
    }
    
    /**
    Saves the changes made to the habit and adds it to the database. This method is called when the `saveButton` button is tapped.

    - Parameter sender: The button that triggered the action.
    */
    @IBAction func saveChanges(_ sender: Any) {
        // Creates a new Habit instance and assigns updated values from text fields.
        let newHabit = Habit()
        newHabit.name = habitNameTextInput.text
        newHabit.habitDescription = descriptionTextField.text
        newHabit.icon = icon
        newHabit.reminderController = currentReminderController
        newHabit.categories = currentLabels
        newHabit.repeatObject = currentRepeat
        newHabit.metric = currentMetric
        if let colour = colourPreviewView.backgroundColor {
            newHabit.setColor(colour: colour)
        }
        newHabit.startDate = self.startDate
        guard let repeatText = repeatTitleLabel.text, let metricText = metricTitleLabel.text else {
            return
        }
        // Generates the habit details string based on the repeat text and metric text.
        newHabit.habitDetails = repeatText + ", " + metricText
        let center = UNUserNotificationCenter.current()
        // If habit has assigned ID, create notification requests for each reminder in the reminder controller.
        if let habit_id = newHabit.id {
            for reminder in currentReminderController!.allReminders {
                let content = UNMutableNotificationContent()
                content.title = "Habit Reminder: \(newHabit.name!)"
                content.body = "Have you completed '\(newHabit.name!)' yet?"
                var dateComponents = DateComponents()
                dateComponents.hour = reminder.hour
                dateComponents.minute = reminder.minute
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "\(habit_id)_reminder", content: content, trigger: trigger)
                center.add(request)
            }
        }
        // Adds the habit to the database controller, and current view controller is dismissed.
        if let habitAdded = databaseController?.addHabit(habit: newHabit) {
            if habitAdded {
                dismiss(animated: true)
            }
        }
    }
    
    /**
     Handles tap gesture when repeat label is tapped.
     
     - Parameter sender: The repeat label that is tapped.
     */
    @IBAction func repeatLabelTouched(_ sender: Any) {
        performSegue(withIdentifier: SEGUE_REPEAT, sender: self)
    }
    
    /**
     Handles tap gesture when category label is tapped.
     
     - Parameter sender: The category label that is tapped.
     */
    @IBAction func categoryLabelTouched(_ sender: Any) {
        performSegue(withIdentifier: SEGUE_LABEL, sender: self)
    }
    
    /**
     Handles tap gesture when metric label is tapped.
     
     - Parameter sender: The metric label that is tapped.
     */
    @IBAction func metricLabelTouched(_ sender: Any) {
        performSegue(withIdentifier: SEGUE_METRIC, sender: self)
    }
    
    /**
     Handles tap gesture when notification label is tapped.
     
     - Parameter sender: The notification label that is tapped.
     */
    @IBAction func notificationLabelTouched(_ sender: Any) {
        performSegue(withIdentifier: SEGUE_REMINDERS, sender: self)
    }
    // MARK: - Text Field Delegate
    
    /**
     Informs the text  field delegate that the return button was pressed on the keyboard.
     
     This method is called when the user taps the return button on the keyboard while editing a text field. It resings the first responder status of the text field, which dismisses the keyboard. Additionally, it returns a booleran value indicating whether a text field should process the return button press.
     
     - Parameter textField: The text field for which the return button was pressed.
     - Returns: A boolean value indicating whether the text field should process the return button press.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     Overrides the default behaviour when touches are detected on the screen.
     
     This method is called when the user touches the screen. It is used to handle the event when the user taps outside of a text field, dismissing the keyboard. By calling `endEditing(true)` on the view, it resigns the first responder status of any active text field, causing the keyboard to be dismissed.

     - Parameters:
        - touches: A set of `UITouch` objects representing the touches that occurred.
        - event: The event that encapsulates the touches for handling multitouch interactions.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Create initial objects
    
    /**
     Creates the initial repeat object
     
     - Returns: A default `Repeat` object, with daily repetitions with all days.
     */
    func createDefaultRepeatObject() -> Repeat {
        let repeatObject = Repeat()
        repeatObject.type = RepeatType.daily
        repeatObject.daysArray = [DaysOfWeek.monday.rawValue,DaysOfWeek.tuesday.rawValue, DaysOfWeek.wednesday.rawValue, DaysOfWeek.thursday.rawValue, DaysOfWeek.friday.rawValue, DaysOfWeek.saturday.rawValue, DaysOfWeek.sunday.rawValue]
        repeatObject.monthlyTimes = 1
        repeatObject.weeklyTimes = WeeklyTimeStruct(numberOfTimes: 1, weeklyPeriod: "Weekly")
        return repeatObject
    }
    
    /**
     Creates a initial `Labels` object
     
     - Returns: A default `Labels` object with "Morning" label selected.
     */
    func createDefaultLabelsObject() -> Labels {
        let labelsObject = Labels()
        labelsObject.selectLabel(labelName: "Morning")
        return labelsObject
    }
    
    /**
     Creates a initial `Metric` object.
     
    - Returns: A default `Metric` class that is frequency based.
     */
    func createDefaultMetricObject() -> Metric{
        let defaultMetric = Metric()
        defaultMetric.type = .frequency
        defaultMetric.totalFrequency = 1
        defaultMetric.totalTime = 0
        return defaultMetric
    }
    
    // MARK: - Delegation Methods
    
    func updateRepeat() {
        guard let currentRepeat else {
            return
        }
        // Updates the repeat label text according `currentRepeat` variable
        toggleSaveButton()
        setupRepeatTitle(repeatObject: currentRepeat, repeatTitleLabel: repeatTitleLabel)
    }
    
    func updateLabels() {
        guard let currentLabels else {
            return
        }
        // Updates the categories label text according `currentLabels` variable
        setupLabelsTitle(categories: currentLabels, categoriesLabel: namedLabelTitleLabel)
    }
    
    func updateMetric() {
        guard let currentMetric else {
            return
        }
        // Updates the metric label text according to currentMetric variable
        toggleSaveButton()
        setupMetricTitle(metric: currentMetric, metricLabel: metricTitleLabel, metricIcon: metricIcon)
    }
    
    func updateIcon(_ icon: String) {
        self.icon = icon
        // Updates the icon on the icon button
        setupIcon(icon: icon, iconButton: iconButton)
    }
    
    func updateReminderControllerDelegate() {
        guard let currentReminderController else {
            return
        }
        // Updates the notifications label according to the current reminder controller settings.
        setupReminderTitle(reminder: currentReminderController, reminderLabel: notificationsLabel)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == SEGUE_REPEAT {
            if let destination = segue.destination as? RepeatViewController{
                destination.repeatDelegate = self
                destination.repeatObject = currentRepeat
            }
        }
        // Gets the destination with segue.destination and sets the delegate as self.
        if segue.identifier == SEGUE_LABEL {
            if let destination = segue.destination as? LabelViewController {
                destination.delegate = self
                destination.currentLabels = currentLabels
            }
        }
        // Gets the destination of segue and sets the delegate, and passes the currentMetric object.
        if segue.identifier == SEGUE_METRIC {
            if let destination = segue.destination as? MetricViewController{
                destination.delegate = self
                destination.currentMetric = currentMetric
            }
        }
        // Gets the destination of the segue and sets the delegate.
        if segue.identifier == SEGUE_ICON {
            if let destination = segue.destination as? IconCollectionViewController {
                destination.delegate = self
            }
        }
        // Gets the destination of the segue and sets the delegate, and passes the currentRemindersController to the destination.
        if segue.identifier == SEGUE_REMINDERS {
            if let destination = segue.destination as? SetRemindersViewController {
                destination.delegate = self
                destination.remindersController = currentReminderController
            }
        }
    }
    

}
