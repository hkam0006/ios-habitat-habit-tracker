//
//  ReminderProtocol.swift
//  ios-habit-app
//
//  Created by Soodles . on 25/4/2023.
//

import Foundation
/**
 A class that represents reminder settings for a habit.
 
 The `RemindersController` class stores information related to reminders for a particular habit. It stores all the reminders set for a habit in a array of `Reminder` objects.
 */
class RemindersController: NSObject, Codable {
    // All reminders for the particular habit.
    var allReminders: [Reminder] = []
    
    private enum CodingKeys: String, CodingKey {
        case allReminders
    }
    
    // Adds a reminder to the list of reminders
    func addReminder(_ reminder: Reminder){
        allReminders.append(reminder)
    }
    
    // Removes a reminder from the list of reminders
    func removeReminder(_ reminder: Reminder){
        allReminders.removeAll { (rem) in
            if rem.hour == reminder.hour && rem.minute == reminder.minute {
                return true
            } else {
                return false
            }
        }
    }
    
    func setNewReminders(_ newReminders: [Reminder]){
        // TODO: method that removes previous reminders and sets new reminders
    }
    /**
     Creates a copy of the `RemindersController` class.
     
     - Returns: A new instance of the `RemindersController` with the same reminders values as the original object.
     */
    func copy() -> RemindersController {
        let newReminderController = RemindersController()
        for reminder in self.allReminders {
            newReminderController.allReminders.append(reminder.copy())
        }
        return newReminderController
    }
}

/**
 A class that represents a reminder for a habit.
 
 The `Reminder` object stores information such as hour and minute of the reminder. A reminder will be sent everyday if permissiosn allow regardless of the repeat time period.
 */
class Reminder: NSObject, Codable {
    // The hour of the reminder
    var hour: Int?
    
    // The minute of the reminder
    var minute: Int?
    
    private enum CodingKeys: String, CodingKey {
        case hour
        case minute
    }
    
    /**
     Comparing two Reminder objects.
     
     - Returns:
        - true: if both reminders have the same hour and minute
        - false: if not
     */
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        if lhs.hour == rhs.hour && lhs.minute == rhs.minute {
            return true
        } else {
            return false
        }
    }
    
    /**
     Creates a new copy of the `Reminder` object.
     
     - Returns: A new instance of the `Reminder` class with the same hour and minute values as the original object.
     */
    func copy() -> Reminder {
        let reminder = Reminder()
        reminder.hour = hour
        reminder.minute = minute
        return reminder
    }
}

/**
 
 */
protocol ReminderDelegate {
    var currentReminderController: RemindersController? {get set}
    func updateReminderControllerDelegate()
}
