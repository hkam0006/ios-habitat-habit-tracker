//
//  FrequencyMetricViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 22/4/2023.
//

import UIKit


private let titles = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "100", "101", "102", "103", "104", "105", "106", "107", "108", "109", "110", "111", "112", "113", "114", "115", "116", "117", "118", "119", "120"]

class FrequencyMetricViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var frequencyPicker: UIPickerView!
    // Metric delegate
    var delegate: MetricDelegate?
    // Current metric settings
    var currentMetric: Metric?
    
    // Set up view controller
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up picker view delegate and datasource
        frequencyPicker.delegate = self
        frequencyPicker.dataSource = self
        
        // Check if metric and total frequency objects exist.
        guard let currentMetric, let freq = currentMetric.totalFrequency else {
            return
        }
        // Select row according to habit metric settings.
        frequencyPicker.selectRow(freq - 1, inComponent: 0, animated: false)
    }
    // MARK: - Picker view data source
    
    // Number of components for picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // Number of rows in components
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1{
            return 1
        } else {
            return titles.count
        }
    }
    
    // Title for each row.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return titles[row]
        } else {
            return "times"
        }
    }
    
    // Handle selecting row.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let currentMetric else {
            return
        }
        if component == 0 {
            currentMetric.totalFrequency = Int(titles[row])!
        }
    }
}
