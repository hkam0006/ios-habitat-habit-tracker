//
//  HabitProtocol.swift
//  ios-habit-app
//
//  Created by Soodles . on 25/4/2023.
//

import UIKit
import Foundation
import FirebaseFirestoreSwift

/**
 Protocol that defines methods that need to implemented for classes that inherit the `NewHabitDelegate` protocol.
 */
protocol NewHabitDelegate {
    // The starting date of the new habit.
    var selectedDate: Date {get set}
    /**
     Creates a new habit.
     
     - Parameters:
        - newHabit: The new habit to be added to the database.
     */
    func addHabit(_ newHabit: Habit)
}

/**
 A class that represents a habit.
 
 The `Habit` class stores information related to the habit. Information such as id, colour, name, description, icon, habit start date, `ReminderController` that stores the reminders for the habit, `Labels` that stores all the labels related to the habit, `Metric` representing the metric information, and `Repeat` class to store the repetitiong settings for the habit. The habit class also stores information such as progress in a dictionary.
 */
class Habit: NSObject, Codable {
    // unique habit id
    var id: String? = UUID().uuidString
    // Red component of habit colour
    var redComponent: Float?
    // Green component of habit colour
    var greenComponent: Float?
    // Blue component of habit colour
    var blueComponent: Float?
    // Alpha component of habit colour
    var alphaComponent: Float?
    // The name of the habit
    var name: String?
    // The description of the habit.
    var habitDescription: String?
    // The icon of the description
    var icon: String?
    // The reminders controller for the habit
    var reminderController: RemindersController?
    // The category of the habit
    var categories: Labels?
    // The metric settings for the habit
    var metric: Metric?
    // The repetition settings for the habit
    var repeatObject: Repeat?
    // The start date of the habit
    var startDate: Date? {
        didSet {
            guard let startDate else {
                return
            }
            progressDictionary[self.dateToString(date: startDate)] = 0.0
        }
    }
    // A string that represents the details of the habit
    var habitDetails: String?
    // A dictionary that stores progress for the habit.
    private var progressDictionary = [String:Float]()
    
    private enum CodingKeys: String, CodingKey {
        case id
        case redComponent
        case greenComponent
        case blueComponent
        case alphaComponent
        case name
        case habitDescription
        case icon
        case startDate
        case habitDetails
        case progressDictionary
        case reminderController
        case metric
        case categories
        case repeatObject
    }
    
    /**
     Sets the colour theme of the habit.
     
     - Parameters:
        - colour: The colour theme that is being set.
     */
    func setColor(colour: UIColor){
        let coreImageColor = CIColor(color: colour)
        redComponent = Float(coreImageColor.red)
        greenComponent = Float(coreImageColor.green)
        blueComponent = Float(coreImageColor.blue)
        alphaComponent = Float(coreImageColor.alpha)
    }
    
    /**
     Getter method of habit's colour theme.
     
     This method is used to get the `redComponent`, `greenComponent`, `blueComponent` and `alphaComponent` of the habit and returns a `UIColor` object. The method returns nil if any of the colour components are missing.
     
     - Returns: A instance of the `UIColor` class with the same red, green, blue and alpha components as habit's theme.
     */
    func getUIColour() -> UIColor?{
        guard let greenComponent,let blueComponent, let redComponent, let alphaComponent else{
            return nil
        }
        return UIColor(red: CGFloat(redComponent), green: CGFloat(greenComponent), blue: CGFloat(blueComponent), alpha: CGFloat(alphaComponent))
    }
    
    /**
     Sets the progress of the habit on a specific date.
     
     This method is used to set the progress value for a specific date in the `progressDictionary`. The progress value is associated with a corresponding date string. If the provided date cannot be converted to a valid date string, the method returns without setting the progress.
     
     - Parameters:
        - date: The date for the which the progress value is to be set
        - progress: The progress value associated with the date.
     */
    func setProgressOnDate(date: Date, progress: Float){
        guard let dateString = dateToBucketString(date: date) else {
            return
        }
        progressDictionary[dateString] = progress
    }
    
    /**
     Gets the progress of the habit on a specific date
     
     This method is used to get the progress value for a specific date in the `progressDictionary`. If there is no progress recorded for the date, the method returns 0.
     
     - Parameters:
        - date: The date of the progress which is to be retrieved
    
     - Returns: The progress value at the specific date if it exists, it not method returns 0.0
     */
    func getProgressOnDate(date: Date) -> Float {
        if let progress = progressDictionary[dateToBucketString(date: date)!] {
            return progress
        } else {
            return 0.0
        }
    }
    
    /**
     Gets the total time of a timed habit.
     
     This method calculates the total time of the habit depending on the repetition and metric settings of the habit. If either `Repeat`, `Metric`, and `Metric.totalTime` does not exist it returns nil value.
     
     - Returns: The total time as a float value.
     */
    func getTotalTime() -> Float?{
        guard let repeatObject,let metric, let totalTime = metric.totalTime else {
            return nil
        }
        if repeatObject.type == RepeatType.daily {
            return Float(totalTime)
        } else if repeatObject.type == RepeatType.weekly {
            if let weeklyTimes = repeatObject.weeklyTimes {
                return Float(totalTime) * Float(weeklyTimes.numberOfTimes)
            }
        } else {
            if let monthlyTimes = repeatObject.monthlyTimes {
                return Float(totalTime) * Float(monthlyTimes)
            }
        }
        return nil
    }
    
    /**
     Increment the completed time for a specific date.
     
     This method increment the time for timed habits. If the `Metric`, `Metric.totalTime` or `Repeat` settings have not been set, the method returns without incrementing the time.
     
     - Parameters:
        - date: The date for which the progress will be updated for.
     */
    func incrementTime(date: Date){
        guard let metric, let totalTime = metric.totalTime, let repeatObject else {
            return
        }
        let currentProgress = getProgressOnDate(date: date)
        if repeatObject.type == RepeatType.daily {
            let progressPerSecond = Float(1) / (Float(totalTime))
            let newProgress = min(currentProgress + progressPerSecond, 1.0)
            setProgressOnDate(date: date, progress: newProgress)
            return
        } else if repeatObject.type == RepeatType.weekly {
            if let numberOfTimes = repeatObject.weeklyTimes?.numberOfTimes {
                let progressPerSecond = Float(1) / (Float(totalTime) * Float(numberOfTimes))
                let newProgress = min(currentProgress + progressPerSecond, 1.0)
                setProgressOnDate(date: date, progress: newProgress)
                return
            }
        } else {
            if let monthlyTimes = repeatObject.monthlyTimes {
                let progressPerSecond = Float(1) / (Float(totalTime) * Float(monthlyTimes))
                let newProgress = min(currentProgress + progressPerSecond, 1.0)
                setProgressOnDate(date: date, progress: newProgress)
                return
            }
        }
    }
    
    /**
     Increments the frequency progress on a specific date for frequency based habits.
     
     This method is used to increment the frequency progress on a specific date based on the repeat type and total frequency of the metric. The progress is updated in the `progressDictionary` associated with the date. If the required metric or repeat object information is not available, the method returns without making any changes.
     
     - Parameter date: The date for which the frequency progress is to be incremented.
     */
    func incrementFrequencyOn(date: Date){
        // Checks if metric, totalFrequency, and repeatObject settings are set, if not then return without incrementing the frequency progress.
        guard let metric, let totalFreq = metric.totalFrequency, let repeatObject = repeatObject else {
            return
        }
        // Gets the current progress for the specific date.
        let currentProgress = getProgressOnDate(date: date)
        if repeatObject.type == RepeatType.daily {
            let addProgress = Float(1) / (Float(totalFreq))
            let newProgress = min(currentProgress + addProgress, 1.0)
            setProgressOnDate(date: date, progress: newProgress)
            return
        } else if repeatObject.type == RepeatType.weekly {
            if let weeklyTimes = repeatObject.weeklyTimes {
                let addProgress = Float(1) / (Float(totalFreq) * Float(weeklyTimes.numberOfTimes))
                let newProgress = min(currentProgress + addProgress, 1.0)
                setProgressOnDate(date: date, progress: newProgress)
                return
            }
        } else {
            if let monthlyTimes = repeatObject.monthlyTimes {
                let addProgress = Float(1) / (Float(totalFreq) * Float(monthlyTimes))
                let newProgress = min(currentProgress + addProgress, 1.0)
                setProgressOnDate(date: date, progress: newProgress)
                return
            }
        }
    }
    
    /**
     Resets the progress value for a specific date.
     
     This method is used to reset the progress value for a specific date in `progressDictionary` to zero. If the provided date cannot be converted into a valid date string, this method returns without making any changes.
     
     - Parameter date: The date for which the progress value is to be reset.
     */
    func resetProgress(date: Date){
        guard let dateString = dateToBucketString(date: date) else {
            return
        }
        progressDictionary[dateString] = 0
    }
    
    /**
     A method that converts a given date to a string representation.
     
     This method is used to convert a given `date` object to a string representation using the specified date format. The converted string represents the date in the format "dd/MM/YY".
     
     - Parameter date: The date to be converted to a string.
     - Returns: A string representation of the provided date in the format "dd/MM/YY".

     */
    func dateToString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/YY"
        return dateFormatter.string(from: date)
    }
    
    /**
     Checks if the given date falls on any of the weekdays specified in the repeat object.
     
     - Parameter date: The date to check.
     - Returns: `true` if the date falls on a weekday specified in the repeat object, `false` otherwise.
     */
    func isDailyAndContainsWeekday(on date: Date) -> Bool {
        guard let repeatObject else {
            return false
        }
        // Getting weekday component from the date.
        var weekDay = Calendar.current.component(.weekday, from: date)
        
        // Adjusting the weekday index to match the Repeat object's weekday representation
        if weekDay == 1 {
            weekDay = 6
        } else {
            weekDay -= 2
        }
        if repeatObject.type == .daily {
            if repeatObject.daysArray.contains(weekDay){
                return true
            }
        }
        return false
    }
    
    /**
     Converts a given date to a bucket string representation based on the repeat pattern defined by the `repeatObject`.
     
     This method finds the calculates the days between the start date and calculates the start date of each repetition start date.
     
     - Parameters:
        - date: The date to be converted to a bucket string.
     - Returns: A string representation of the provided date in the bucket format determined by the `repeatObject`. Returns `nil` if the conversion is not possible.
     */
    func dateToBucketString(date: Date) -> String? {
        guard let repeatObject, let startDate else {
            return nil
        }
        if date < startDate {
            return nil
        }
        // Calculate the number of days from provided date to habit start date.
        let calendar = Calendar.current
        let fromDate = calendar.startOfDay(for: startDate)
        let toDate = calendar.startOfDay(for: date)
        let dayComponent = calendar.dateComponents([.day], from: fromDate, to: toDate)
        guard let numberOfDays = dayComponent.day else {
            return nil
        }
        //
        if repeatObject.type == .daily {
            // Convert date to string in "dd/MM/YY" format
            return dateToString(date: date)
        }
        else if repeatObject.type == .weekly {
            guard let weeklyTimes = repeatObject.weeklyTimes else {
                fatalError("Repeat Type: weekly but doesn not have data")
            }
            if weeklyTimes.weeklyPeriod == "Weekly"{
                var addDays = DateComponents()
                // Calculate the number of weeks
                addDays.day = (numberOfDays / 7) * 7
                return dateToString(date: Calendar.current.date(byAdding: addDays, to: startDate)!)
            } else if weeklyTimes.weeklyPeriod == "Bi-Weekly" {
                var addDays = DateComponents()
                // Calculate the number of bi-weeks
                addDays.day = (numberOfDays / 14) * 14
                return dateToString(date: Calendar.current.date(byAdding: addDays, to: startDate)!)
            } else {
                var addDays = DateComponents()
                // Calculate the number of tri-weeks
                addDays.day = (numberOfDays / 21) * 21
                return dateToString(date: Calendar.current.date(byAdding: addDays, to: startDate)!)
            }
        } else {
            guard repeatObject.monthlyTimes != nil else {
                fatalError("Repeat Type monthly: but doesnt not have data")
            }
            var addDays = DateComponents()
            // Calculate the number of months
            addDays.day = (numberOfDays / 30) * 30
            return dateToString(date: Calendar.current.date(byAdding: addDays, to: startDate)!)
        }
    }
}
