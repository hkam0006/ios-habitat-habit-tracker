//
//  CalendarUtil.swift
//  ios-habit-app
//
//  Created by Soodles . on 29/4/2023.
//

import Foundation

/**
 A utilitry class for calendar releated and date formatting
 
 The `CalendarUtil` class provides methods for converting dates to formatting strings, getting the next or previous day, and getting the start of a given day.
 */
class CalendarUtil{
    // Calender.current instance of all calendar operations.
    let calendar = Calendar.current
    
    // Changes date to string format.
    func monthDayString(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, LLL dd `YY"
        return dateFormatter.string(from: date)
    }
    
    /**
     Increments the day
     */
    func nextDay(date: Date) -> Date{
        return calendar.date(byAdding: .day, value: 1, to: date)!
    }
    
    /**
     Decrements the day
     */
    func previousDay(date: Date) -> Date {
        return calendar.date(byAdding: .day, value: -1, to: date)!
    }
    
    // Gets the date at 00:00:00
    func getStartOfDay(date: Date) -> Date{
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
    }
}
