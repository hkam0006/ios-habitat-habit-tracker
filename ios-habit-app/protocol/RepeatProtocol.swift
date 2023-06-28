//
//  Protocols.swift
//  ios-habit-app
//
//  Created by Soodles . on 20/4/2023.
//

import Foundation

/**
 Protocol that defines method that need to implemented for classes that adopt the `RepeatDelegate` protocol.
 */
protocol RepeatDelegate {
    // Current metric associated with adopting class.
    var currentRepeat: Repeat? { get set }
    
    /**
     Updates the repeat object associated with adopting class.
     
     This method is called to update the metric associated with the adopting class. It should be implemented by the conforming class to perform any neccessary updates related to the current `Repeat` object.
     */
    func updateRepeat()
}
/**
 Protocol that defines methods that need to implemented for adopting classes of `RepeatPageDelegate`
 */
protocol RepeatPageDelegate {
    var repeatObject: Repeat? { get set }
    func updateRepeat(_ repeatObject: Repeat)
}

/**
 Enumeration that represents different repeat periods of habits.
 
 The `RepeatType` enumeration defines 3 types of repeat types; daily, weekly and monthly.
 */
enum RepeatType: Int {
    case daily = 0
    case weekly = 1
    case monthly = 2
}

/**
 A enumeration that represents different days of the week.
 */
enum DaysOfWeek: Int {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6
}

/**
 A struct that represents the weekly repeat time period habits.
 
 The `WeeklyTimeStruct` contains information related the the weekly repeat time period such as number of times per week and the weekly time period such as weekly, bi-weekly and tri-weekly.
 */
struct WeeklyTimeStruct: Codable {
    // Number of repetitions done on a weekly time period basis
    var numberOfTimes: Int
    
    // Weekly time period
    var weeklyPeriod: String
    
    private enum CodingKeys: String, CodingKey {
        case numberOfTimes
        case weeklyPeriod
    }
    
    /**
     Creates a copy of `WeeklyTimeStruct` struct.
     
     - Returns: A new instance of `WeeklyTimeStruct` with the same property values as the original object.
     */
    func copy() -> WeeklyTimeStruct {
        let newWeeklyTimeStruct = WeeklyTimeStruct(numberOfTimes: self.numberOfTimes, weeklyPeriod: self.weeklyPeriod)
        return newWeeklyTimeStruct
    }
}
/**
 A class representing a repeat settings for a habit.
 
 The `Repeat` class stores information related to the repetition settings, such as the repeat type, days array, daily times, weekly times, and monthly times. It conforms to the `Codable` protocol for easy encoding and decoding, and provides a `copy()` method for creating a copy of the `Repeat` object.

 */
class Repeat: NSObject, Codable {
    // The repeat type of the habit
    var repeatType: Int?
    
    // An array of days for which the habit is repeated for daily habits
    var daysArray: [Int] = []
    
    // The number of times the habit is repeated for daily habits
    var dailyTimes: Int?
    
    // The repetition settings for weekly habit.
    var weeklyTimes: WeeklyTimeStruct?
    
    // The repetitiong settings for monthly habit.
    var monthlyTimes: Int?
    
    private enum CodingKeys: String, CodingKey {
        case repeatType
        case daysArray
        case dailyTimes
        case weeklyTimes
        case monthlyTimes
    }
    
    /**
     Creates a copy of the 'Repeat' object.
     
     - Returns: A new instance of `Repeat` class with the same property.
     */
    func copy() -> Repeat {
        let newRepeat = Repeat()
        newRepeat.repeatType = self.repeatType
        newRepeat.daysArray = self.daysArray
        newRepeat.dailyTimes = self.dailyTimes
        newRepeat.weeklyTimes = weeklyTimes
        newRepeat.monthlyTimes = self.monthlyTimes
        newRepeat.type = self.type
        return newRepeat
    }
    
    /**
     Removes a specific day from the days array.
     
     - Parameters:
        - dayInt: The day to be removed from the days array.
     */
    func removeDailyTime(_ dayInt: Int){
        daysArray.removeAll { (day) in
            if day == dayInt{
                return true
            } else {
                return false
            }
        }
        sortDailyTimes()
    }
    
    /**
     Add days to the days array.
     
     - Parameters:
        - dayInt: The day to be added to the days array.
     */
    func addDailyTime(_ dayInt: Int){
        daysArray.append(dayInt)
        sortDailyTimes()
    }
    
    /**
     Sorts the days array in ascending order.
     */
    func sortDailyTimes(){
        let sorted = daysArray.sorted (by: {$0 < $1})
        daysArray = sorted
    }
    
    
}

extension Repeat {
    /**
     The metric type based on the repeatType property.
     
     This computed property provides a more convenient way to access and set the metric type as `RepeatType` enum value, based on the raw value of the `repeatType` property.
     */
    var type: RepeatType? {
        get {
            return RepeatType(rawValue: self.repeatType!)!
        }
        set {
            guard let newValue else{
                return
            }
            self.repeatType = newValue.rawValue
        }
    }
}

