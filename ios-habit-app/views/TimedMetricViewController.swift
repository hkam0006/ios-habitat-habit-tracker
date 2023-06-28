//
//  TimedMetricViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 22/4/2023.
//

import UIKit

// Private variables
private let hoursAndMinutesAndSeconds = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59"]
private let COMPONENT_HOUR = 0
private let COMPONENT_TITLE_HOUR = 1
private let COMPONENT_MIN = 2
private let COMPONENT_TITLE_MIN = 3
private let COMPONENT_SEC = 4
private let COMPONENT_TITLE_SEC = 5
private let HOURS_TO_SECONDS = 3600
private let MIN_TO_SECONDS = 60

/**
 View controller for customising a time-based metric habit.
 */
class TimedMetricViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var timePicker: UIPickerView!
    // Delegate.
    var delegate: MetricDelegate?
    // current metric variable
    var currentMetric: Metric?
    
    // Handle view controller set up on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up time picker delegate and datasource
        timePicker.dataSource = self
        timePicker.delegate = self
        // Do any additional setup after loading the view.
        //
        guard let currentMetric, let numberOfSeconds = currentMetric.totalTime else {
            return
        }
        // Select time componenets from total time from metric object.
        let timeComponents = numberOfSeconds.toTimeComponents()
        timePicker.selectRow(timeComponents.0, inComponent: COMPONENT_HOUR, animated: false)
        timePicker.selectRow(timeComponents.1, inComponent: COMPONENT_MIN, animated: false)
        timePicker.selectRow(timeComponents.2, inComponent: COMPONENT_SEC, animated: false)
    }
    
    // The number of componenets in the time picker.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        6
    }
    
    // The number of rows for each component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // 24 rows for each hour
        if component == COMPONENT_HOUR {
            return 24
        }
        // 60 rows for minutes/seconds.
        else if component == COMPONENT_MIN || component == COMPONENT_SEC {
            return 60
        }
        // Rows for headings e.g, "hr", "min" and "sec"
        else {
            return 1
        }
    }
    
    // Sets up the title for each row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Title for row title
        if component == COMPONENT_TITLE_HOUR{
            return "hr"
        }
        else if component == COMPONENT_TITLE_MIN {
            return "min"
        }
        else if component == COMPONENT_TITLE_SEC {
            return "sec"
        } else {
            return hoursAndMinutesAndSeconds[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let currentMetric else {
            return
        }
        var totalSeconds = 0
        // Calculating total seconds when hour component is selected.
        if component == COMPONENT_HOUR {
            totalSeconds += Int(hoursAndMinutesAndSeconds[row])! * HOURS_TO_SECONDS
            totalSeconds += Int(hoursAndMinutesAndSeconds[pickerView.selectedRow(inComponent: COMPONENT_MIN)])! * MIN_TO_SECONDS
            totalSeconds += Int(hoursAndMinutesAndSeconds[pickerView.selectedRow(inComponent: COMPONENT_SEC)])!
        }
        // Calculating total seconds when minute component is selected.
        else if component == COMPONENT_MIN {
            totalSeconds += Int(hoursAndMinutesAndSeconds[pickerView.selectedRow(inComponent: COMPONENT_HOUR)])! * HOURS_TO_SECONDS
            totalSeconds += Int(hoursAndMinutesAndSeconds[row])! * MIN_TO_SECONDS
            totalSeconds += Int(hoursAndMinutesAndSeconds[pickerView.selectedRow(inComponent: COMPONENT_SEC)])!
        }
        // Calculating total seconds when second component is selected.
        else if component == COMPONENT_SEC {
            totalSeconds += Int(hoursAndMinutesAndSeconds[pickerView.selectedRow(inComponent: COMPONENT_HOUR)])! * HOURS_TO_SECONDS
            totalSeconds += Int(hoursAndMinutesAndSeconds[pickerView.selectedRow(inComponent: COMPONENT_MIN)])! * MIN_TO_SECONDS
            totalSeconds += Int(hoursAndMinutesAndSeconds[row])!
        }
        currentMetric.totalTime = totalSeconds
    }

}

extension Int {
    /**
     Converts an integer value to time components (hour, minutes, seconds)
     
     - Returns: A tuple containing the time components in the format (hour, minutes, seconds)
     */
    func toTimeComponents() -> (Int, Int, Int){
        var result = (0,0,0)
        var seconds = self
        result.0 = seconds / 3600
        seconds = seconds % 3600
        result.1 = seconds / 60
        result.2 = seconds % 60
        return result
    }
}
