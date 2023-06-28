//
//  HabitModification.swift
//  ios-habit-app
//
//  Created by Soodles . on 15/5/2023.
//

import UIKit
/**
 A protocol that defines methods for adopting classes of `HabitModification`.
 */
protocol HabitModification: NSObject {
    func daysToString(repeatObject: Repeat) -> String?
    func setupRepeatTitle(repeatObject: Repeat, repeatTitleLabel: UILabel)
    func setupMetricTitle(metric: Metric, metricLabel: UILabel, metricIcon: UIImageView)
    func setupIcon(icon: String, iconButton: UIButton)
    func setupLabelsTitle(categories: Labels, categoriesLabel: UILabel)
}

extension HabitModification {
    /**
     Converts an array of day values from `Repeat` object into a string representation.
     
     - Parameter repeatObject: The `Repeat` object containing the array of day values
     - Returns: A string representation of the days, seperated by commas.
     */
    func daysToString(repeatObject: Repeat) -> String? {
        var labelStringArray: [String] = []
        // Loop through days array and append string to array
        for day in repeatObject.daysArray {
            switch day{
            case DaysOfWeek.monday.rawValue:
                labelStringArray.append("Mon")
            case DaysOfWeek.tuesday.rawValue:
                labelStringArray.append("Tue")
            case DaysOfWeek.wednesday.rawValue:
                labelStringArray.append("Wed")
            case DaysOfWeek.thursday.rawValue:
                labelStringArray.append("Thu")
            case DaysOfWeek.friday.rawValue:
                labelStringArray.append("Fri")
            case DaysOfWeek.saturday.rawValue:
                labelStringArray.append("Sat")
            default:
                labelStringArray.append("Sun")
            }
        }
        // Join array of strings with comma and return it.
        return labelStringArray.joined(separator: ",")
    }
    
    /**
     Sets up repeat title label text according to the `Repeat` object.
     
     - Parameters:
        - repeatObject: The `Repeat` object that provides information about habit repetition.
        - repeatTitleLabel: The `UILabel` object that will updated.
     */
    func setupRepeatTitle(repeatObject: Repeat, repeatTitleLabel: UILabel){
        let repeatType = repeatObject.type
        switch repeatType {
            case .monthly:
                guard let num = repeatObject.monthlyTimes else {
                    return
                }
                if num == 1 {
                    repeatTitleLabel.text = "Once per Month"
                }
                else {
                    repeatTitleLabel.text = "\(String(num)) times per month"
                }
            case .weekly:
                guard let weeklyInformation = repeatObject.weeklyTimes else {
                    return
                }
                repeatTitleLabel.text = "\(weeklyInformation.numberOfTimes) times per \(weeklyInformation.weeklyPeriod)"
            default:
                if repeatObject.daysArray.count == 7 {
                    repeatTitleLabel.text = "Everyday"
                }
                else if repeatObject.daysArray.count == 0 {
                    repeatTitleLabel.text = "None"
                }
                else if repeatObject.daysArray.count == 2 {
                    if repeatObject.daysArray.contains(DaysOfWeek.saturday.rawValue) && repeatObject.daysArray.contains(DaysOfWeek.sunday.rawValue){
                        repeatTitleLabel.text = "Weekends"
                    } else {
                        repeatTitleLabel.text = daysToString(repeatObject: repeatObject)
                    }
                }
                else if repeatObject.daysArray.count == 5 {
                    if !repeatObject.daysArray.contains(DaysOfWeek.saturday.rawValue) && !repeatObject.daysArray.contains(DaysOfWeek.sunday.rawValue){
                        repeatTitleLabel.text = "Weekdays"
                    } else {
                        repeatTitleLabel.text = daysToString(repeatObject: repeatObject)
                    }
                } else {
                    repeatTitleLabel.text = daysToString(repeatObject: repeatObject)
                }
        }
    }
    
    /**
     Sets up the metric title label text and metric icon according to the `Metric` object provided.
     
     - Parameters:
        - metric: The `Metric` object that contains information about habit measurement for example, time and frequency based habits
        - metricLabel: The `UILabel` that will be updated.
        - metricIcon: The `UIImageView` that represents the metric icon
     */
    func setupMetricTitle(metric: Metric, metricLabel: UILabel, metricIcon: UIImageView){
        if metric.type == .frequency {
            metricIcon.image = UIImage(systemName: "arrow.triangle.2.circlepath.circle" )
            guard  let numOfTimes = metric.totalFrequency else {
                return
            }
            metricLabel.text = "\(numOfTimes) times"
        }
        else {
            metricIcon.image = UIImage(systemName: "timer.square")
            guard let numOfSeconds = metric.totalTime else {
                return
            }
            let timeComponents = numOfSeconds.toTimeComponents()
            if timeComponents.0 == 0 && timeComponents.1 == 0 {
                metricLabel.text = "\(timeComponents.2) seconds"
            }
            else if timeComponents.0 == 0 {
                let float_value = Float(timeComponents.1) + (Float(timeComponents.2) / Float(60))
                metricLabel.text = "\( String(format: "%.1f", float_value)) minutes"
            }
            else if timeComponents.0 != 0 {
                let float_value = Float(timeComponents.0) + (Float(timeComponents.1) / Float(60))
                metricLabel.text = "\( String(format: "%.1f", float_value)) hours"
            }
            
        }
    }
    
    /**
     Sets up the habit icon for the icon button.
     
     - Parameters:
        - icon: A string that represents the habit icon.
        - iconButton: The `UIButton` that will contain the habit icon.
     */
    func setupIcon(icon: String, iconButton: UIButton){
        iconButton.setTitle(icon,for:.normal)
    }
    
    /**
     Sets up the categories labels according to the `Labels` object.
     
     - Parameters:
        - categories: The `Labels` object that stores information about selected labels of the habit.
        - categoriesLabel: The `UILabel` object that will be updated.
     */
    func setupLabelsTitle(categories: Labels, categoriesLabel: UILabel){
        if categories.selectedLabels.count == 1 {
            categoriesLabel.text = categories.selectedLabels.first
        }
        else if categories.selectedLabels.count == 0 {
            categoriesLabel.text = "None"
        }
        else {
            categoriesLabel.text = "Multiple"
        }
    }
    
    /**
     Sets up the reminder labels according the the `RemindersController` object.
     
     - Parameters:
        - reminder: The `RemindersController` object that stores information about the reminders for the habit.
        - reminderLabel: The `UILabel` object that will be updated.
     */
    func setupReminderTitle(reminder: RemindersController, reminderLabel: UILabel){
        if reminder.allReminders.count == 0 {
            reminderLabel.text = "None"
        } else if reminder.allReminders.count == 1 {
            reminderLabel.text = "1 Reminder"
        }
        else {
            reminderLabel.text = "\(reminder.allReminders.count) reminders"
        }
    }
}
