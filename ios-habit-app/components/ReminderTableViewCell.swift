//
//  ReminderTableViewCell.swift
//  ios-habit-app
//
//  Created by Soodles . on 25/4/2023.
//

import UIKit
/**
 A class that represents a reminder cell in table view in `SetRemindersViewController`. Each cell has a reminder label and a date picker for the user to set reminder time.
 */
class ReminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var reminderLabel: UILabel!
    var reminder: Reminder?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        guard let reminder else {
            return
        }
        var dateComponents = DateComponents()
        dateComponents.hour = reminder.hour
        dateComponents.minute = reminder.minute
        let userCalendar = Calendar(identifier: .gregorian)
        if let setDate = userCalendar.date(from: dateComponents) {
            timePicker.setDate(setDate, animated: false)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // Action that sets the reminder class's hour and minute attribute on date picker change.
    @IBAction func timeChanged(_ sender: Any) {
        guard let reminder else {
            return
        }
        let date = timePicker.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else {
            return
        }
        reminder.hour = hour
        reminder.minute = minute
    }
}

/**
 A class that represents a cell for adding a new reminder.
 */
class AddReminderTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
