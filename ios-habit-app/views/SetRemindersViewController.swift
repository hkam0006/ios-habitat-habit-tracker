//
//  SetRemindersViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 25/4/2023.
//

import UIKit
import UserNotifications

// Private variables for the SetRemindersViewController
private let CELL_ADD = "addReminderCell"
private let CELL_REMINDER = "reminderCell"
private let SECTION_REMINDERS = 0
private let SECTION_ADD = 1
/**
 View controller for setting reminders.
 */
class SetRemindersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // The reminders table view
    @IBOutlet weak var remindersTableView: UITableView!
    // Button toggle for reminders
    @IBOutlet weak var remindersSwitch: UISwitch!
    // The reminder controller associated with the view controller
    var remindersController: RemindersController?
    // The delegate of the view controller.
    var delegate: ReminderDelegate?
    
    // Initial set up of the view controller.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up table view delegate and data source
        remindersTableView.delegate = self
        remindersTableView.dataSource = self
        
        // Set up button according to ReminderContoller settings.
        guard let remindersController else {
            return
        }
        if remindersController.allReminders.count == 0 {
            remindersSwitch.isOn = false
            remindersTableView.isHidden = true
        } else {
            remindersSwitch.isOn = true
            remindersTableView.isHidden = false
        }
    }
    
    /**
     Requests permission to send local notifications if the authorisation status is not determined or denied.
     */
    func requestNotificationsPermission(){
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied {
                center.requestAuthorization(options: [.alert]) { success, error in
                    if success {
                        print("NOTIFICATIONS ENABLED")
                    } else if let error = error{
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    /**
     Handle interaction when toggling reminders switch
     */
    @IBAction func toggleReminders(_ sender: Any) {
        guard let remindersController else {
            return
        }
        // If reminder is off, hide the table view.
        if !remindersSwitch.isOn {
            remindersController.allReminders = []
            remindersTableView.isHidden = true
            remindersTableView.reloadData()
        }
        // If reminder is on, show the table view
        else {
            remindersTableView.isHidden = false
        }
    }
    
    /**
     Adds a reminder.
     
     The method adds a reminder to the `RemindersController` and also adds it to the table view. If the `RemindersController` is not set up, then it does not do anything.
     */
    @IBAction func addReminder(_ sender: Any) {
        guard let remindersController else {
            return
        }
        let defaultReminder = Reminder()
        remindersController.addReminder(defaultReminder)
        let indexPath = IndexPath(row: remindersController.allReminders.count - 1, section: 0)
        remindersTableView.insertRows(at: [indexPath], with: .fade)
    }
    
    
    // MARK: - Table view data source
    
    /**
     The number of rows in each section. If the reminders controller is not set up, it returns 0.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let remindersController else {
            return 0
        }
        // The number of rows in reminders section.
        if section == SECTION_REMINDERS {
            return remindersController.allReminders.count
        }
        // The add reminder section has one cell for adding reminders.
        else {
            return 1
        }
    }
    /**
     The view controller has two sections, reminders and adding reminders.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /**
     Setting up cells for each of the sections.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Setting up cells in the reminders section
        if indexPath.section == SECTION_REMINDERS {
            // Dequeue cell with CELL_REMINDER identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_REMINDER, for: indexPath) as! ReminderTableViewCell
            cell.selectionStyle = .none
            // Setting label and cell for each reminder.
            if let remindersController {
                cell.reminder = remindersController.allReminders[indexPath.row]
                cell.reminderLabel.text = "Reminder \(indexPath.row + 1)"
                cell.awakeFromNib()
            }
            return cell
        }
        // Setting up cells in the adding reminders section.
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ADD, for: indexPath) as! AddReminderTableViewCell
            cell.selectionStyle = .none
            return cell
        }
    }
    
    /**
     Setting the editing cells.
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Only handle deleting reminders, user cannot delete the Add Reminder cell.
        if editingStyle == .delete && indexPath.section == SECTION_REMINDERS {
            tableView.performBatchUpdates({
                guard let rc = self.remindersController else {
                    return
                }
                rc.allReminders.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections([SECTION_REMINDERS], with: .automatic)
            }, completion: nil)
        }
    }
    
    // MARK: - Navigation
    
    /**
     Requests notification permission from the user.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestNotificationsPermission()
    }
    
    /**
     Updates the `ReminderDelegate` delegate of changes done within this view controller when this view controller disappears from the view.
     */
    override func viewWillDisappear(_ animated: Bool) {
        guard let delegate else {
            return
        }
        delegate.updateReminderControllerDelegate()
    }
}
