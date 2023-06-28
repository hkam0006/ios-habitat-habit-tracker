//
//  DailyRepeatViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 20/4/2023.
//

import UIKit

private let rows = [
    ("mondayCell", "Monday"),
    ("tuesdayCell", "Tuesday"),
    ("wednesdayCell", "Wednesday"),
    ("thursdayCell", "Thursday"),
    ("fridayCell", "Friday"),
    ("saturdayCell", "Saturday"),
    ("sundayCell", "Sunday")
]

/**
 View controller for customising daily repetition
 */
class DailyRepeatViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    // Daily Table View
    @IBOutlet weak var tableView: UITableView!
    // An array that keeps track of selected indexes
    var selectedRows: [Int] = []
    
    // Repeat page delegate
    var delegate: RepeatPageDelegate?
    // Repeat object
    var repeatObject: Repeat?
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting table view delegate and data source
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.isScrollEnabled = false
    }
    // MARK: - Table view data source
    
    // Cell for row in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rows[indexPath.row].0, for: indexPath)
        cell.textLabel?.text = rows[indexPath.row].1
        cell.selectionStyle = .none
        if selectedRows.contains(indexPath.row){
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            cell.accessoryType = .checkmark
        } else {
            cell.isSelected = false
            cell.accessoryType = .none
        }
        return cell
    }
    
    // Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    // Handle when user selects a table view cell.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.accessoryType = .checkmark
        guard let repeatObject = repeatObject else {
            return
        }
        repeatObject.addDailyTime(indexPath.row)
        delegate?.updateRepeat(repeatObject)
    }
    
    // Handles deselecting table view cell.
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath), let repeatObject else {
            return
        }
        cell.accessoryType = .none
        repeatObject.removeDailyTime(indexPath.row)
        delegate?.updateRepeat(repeatObject)
    }
}
