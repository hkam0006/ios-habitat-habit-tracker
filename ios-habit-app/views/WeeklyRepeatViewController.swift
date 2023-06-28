//
//  WeeklyRepeatViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 20/4/2023.
//

import UIKit

private let numberOfTimesTitle = ["Once", "Twice","3 times","4 times","5 times","6 times","7 times","8 times","9 times","10 times","11 times","12 times","13 times","14 times","15 times"]
private let middleTitle = ["per"]
private let frequencyTitle = ["Weekly", "Bi-Weekly", "Tri-Weekly"]
private var titles = [numberOfTimesTitle, middleTitle, frequencyTitle]
private let TITLE_TIMES = 0
private let TITLE_MIDDLE = 1
private let TITLE_PERIOD = 2
/**
 View controller for customising weekly repetition settings for habits customisation.
 */
class WeeklyRepeatViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // Weekly frequency picker
    @IBOutlet weak var pickerView: UIPickerView!
    
    // Delegate
    var delegate: RepeatPageDelegate?
    // Repeat Object reference.
    var repeatObject: Repeat?
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setting up picker view delegate and data source
        pickerView.delegate = self
        pickerView.dataSource = self
        guard let repeatObject = repeatObject, let weeklyInformation = repeatObject.weeklyTimes else {
            return
        }
        
        // Get index from number of times variable from repeat object.
        let timesIndex = weeklyInformation.numberOfTimes - 1
        guard let frequencyIndex = frequencyTitle.firstIndex(of: weeklyInformation.weeklyPeriod) else {
            return
        }
        // Select rows with weekly repeat object information
        pickerView.selectRow(timesIndex, inComponent: 0, animated: false)
        pickerView.selectRow(frequencyIndex, inComponent: 2, animated: false)
    }
    
    
    // MARK: - Picker view data source
    // The number of componenets in the picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // Setting the number of rows each component.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Setting titles for times component
        if component == TITLE_TIMES {
            return titles[TITLE_TIMES].count
        }else if component == TITLE_MIDDLE { //Setting title for middle component
            return titles[TITLE_MIDDLE].count
        } else { // Setting title for weekly period component
            return titles[TITLE_PERIOD].count
        }
        
    }
    
    // Setting titles for each of the rows.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return titles[component][row]
    }
    
    // Setting up width for each of the components in the picker.
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        // Setting titles for frequency component in date picker
        if component == TITLE_TIMES {
            return CGFloat(150)
        }
        // Setting title for middle component
        else if component == TITLE_MIDDLE {
            return CGFloat(60)
        }
        // Setting title width for weekly period component
        else{
            return CGFloat(150)
        }
    }
    
    // Handle user interaction when row is selected on picker.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let repeatObject = repeatObject, let delegate = delegate else {
            return
        }
        let title = frequencyTitle[pickerView.selectedRow(inComponent: 2)]
        let times = pickerView.selectedRow(inComponent: 0) + 1
        repeatObject.weeklyTimes = WeeklyTimeStruct(numberOfTimes: times, weeklyPeriod: title)
        delegate.updateRepeat(repeatObject)
    }
}
