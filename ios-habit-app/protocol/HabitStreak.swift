//
//  HabitStreak.swift
//  ios-habit-app
//
//  Created by Soodles . on 13/5/2023.
//

import UIKit

/**
 A class that represents habit streaks until a specific date.
 */
class HabitStreak: NSObject {
    // The date of the habit streak
    let endDate: Date
    // The habit
    let habit: Habit
    // Used for date formatting
    var dateFormatter = DateFormatter()
    // A array of tuples the represent the date string and progress value
    var progressArray = [(String, Float)]()
    // The current streak of the habit.
    var currentStreak: Int = 0
    
    /**
     Initialisation method
     
     When a new `HabitStreak` object is initialised, it generates the progress array using information provided by the `Habit` and the `Date` object.
     
     - Parameters:
        - habit: the `Habit` object that contains habit information
        - date: the date of the streak.
     */
    init(habit: Habit, date: Date){
        self.endDate = date
        self.habit = habit
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "dd/MM/YY"
        
        super.init()
        
        self.generateProgressArray()
        
    }
    
    /**
     Gets the progress array variable
     
     - Returns: The array of date strings and progress values
     */
    func getProgressArray() -> [(String, Float)] {
        return self.progressArray
    }
    
    /**
     Gets the total time of the habit.
     
     - Returns: The total time of the `Habit` as a float value.
     */
    func getHabitTotalTime() -> Float? {
        return habit.getTotalTime()
    }
    
    /**
     Generates an array of progress data for each date within the habit's start and end dates.

     This function iterates through the dates starting from the habit's start date until the end date. For each date, it retrieves the progress value using `habit.getProgressOnDate(date:)` and appends the date and progress value to the `progressArray`. If the progress value is equal to or greater than 1.0, the current streak is incremented and the progress value is set to 1.0 in the `progressArray`. If the current date is not the same as the end date, the current streak is reset to 0. The iteration continues based on the repeat type of the habit. For daily habits, the iteration increments the current date by 1 day. For weekly habits, it increments the current date by a variable number of days depending on the weekly period specified in `repeatObject.weeklyTimes`. For monthly habits, it increments the current date by 30 days.
     
     - Precondition: The `habit.startDate`, `habit.repeatObject`, and `endDate` properties must be properly set before calling this function.

     - Note: This function relies on the `dateFormatter` and `currentStreak` properties being properly initialized and accessible within the scope.
     */
    func generateProgressArray(){
        guard var currentDate = habit.startDate, let repeatObject = habit.repeatObject else {
            return
        }
        let calendar = Calendar.current
        
        while currentDate.compare(endDate) != .orderedDescending {
            let dateString = dateFormatter.string(from: currentDate)
            let progress = habit.getProgressOnDate(date: currentDate)
            var weekDay = Calendar.current.component(.weekday, from: currentDate)
            if weekDay == 1 {
                weekDay = 6
            } else {
                weekDay -= 2
            }
            let isDaily = repeatObject.type == .daily
            let containsWeekday = repeatObject.daysArray.contains(weekDay)
            if progress >= 1.0 {
                if isDaily {
                    if containsWeekday {
                        currentStreak += 1
                        progressArray.append((dateString,1.0))
                    }
                } else {
                    currentStreak += 1
                    progressArray.append((dateString,1.0))
                }
            } else if currentDate.compare(endDate) != .orderedSame {
                if isDaily {
                    if containsWeekday {
                        currentStreak = 0
                        progressArray.append((dateString,progress))
                    }
                } else {
                    currentStreak = 0
                    progressArray.append((dateString,progress))
                }
            } else {
                if isDaily {
                    if containsWeekday {
                        progressArray.append((dateString,progress))
                    }
                } else {
                    progressArray.append((dateString,progress))
                }
            }
            
            // Adding days
            if repeatObject.type == .daily {
                if let newDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                    currentDate = newDate
                }
            } else if repeatObject.type == .weekly {
                if repeatObject.weeklyTimes?.weeklyPeriod == "Weekly" {
                    if let newDate = calendar.date(byAdding: .day, value: 7, to: currentDate) {
                        currentDate = newDate
                    }
                } else if repeatObject.weeklyTimes?.weeklyPeriod == "Bi-Weekly" {
                    if let newDate = calendar.date(byAdding: .day, value: 14, to: currentDate){
                        currentDate = newDate
                    }
                } else {
                    if let newDate = calendar.date(byAdding: .day, value: 21, to: currentDate){
                        currentDate = newDate
                    }
                }
            } else {
                if let newDate = calendar.date(byAdding: .day, value: 30, to: currentDate){
                    currentDate = newDate
                }
            }
        }
    }
}
