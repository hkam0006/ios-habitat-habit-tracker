//
//  LabelViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 22/4/2023.
//

import UIKit

private let CELL_LABEL = "labelCell"

/**
 View controller for selecting labels.
 */
class LabelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,DatabaseListener {
    // Listener types
    var listenerType = ListenerType.labels
    // Outlets
    @IBOutlet weak var labelTableView: UITableView!
    @IBOutlet weak var addLabelButton: UIBarButtonItem!
    // Label delegate
    var delegate: LabelDelegate?
    // Current label settings
    var currentLabels: Labels?
    // Database controller
    var databaseController: DatabaseProtocol?
    // List of all labels.
    var allLabels: [String] = []
    
    // Set up view controller on load
    override func viewDidLoad() {
        super.viewDidLoad()
        labelTableView.delegate = self
        labelTableView.dataSource = self
        labelTableView.allowsMultipleSelection = true
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    func onHabitsChange(change: DatabaseChange, habitList: [Habit]) {
        // do nothing
    }
    
    func onLabelChange(change: DatabaseChange, labelList: [String]) {
        allLabels = labelList
        labelTableView.reloadData()
    }
    
    func onFriendsChange(change: DatabaseChange, friendList: [Friend], friendActivity: [String], friendRequest: [Friend]) {
        // do nothing
    }
    
    func onUserChange(change: DatabaseChange) {
        // nothing
    }
    
    // MARK: - Table view data source
    
    // The number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allLabels.count
    }
    
    /**
     Returns a configured cell for the label table view.
     
     - Parameters:
        - tableView: The table view requesting the cell.
        - indexPath: The index path of the cell.
     - Returns: A configured cell for displaying label information.
     - Precondition: `currentLabels` must be loaded before calling this method.
     - Throws: `fatalError` if `currentLabels` is `nil`.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if current labels are available
        guard let currentLabels else {
            fatalError("Labels not loaded")
        }
        // Dequeue a reusable cell
        let cell = labelTableView.dequeueReusableCell(withIdentifier: CELL_LABEL, for: indexPath)
        // Configure the cell
        cell.textLabel?.text = allLabels[indexPath.row]
        cell.selectionStyle = .none
        
        // Check if the current label is selected and set appropriate accessory type.
        if currentLabels.selectedLabels.contains(allLabels[indexPath.row]){
            labelTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        } else {
            cell.isSelected = false
            cell.accessoryType = .none
        }
        return cell
    }
    
    /**
     Handles the selection of a table view cell.
     
     - Parameters:
        - tableView: The table view where the cell was selected.
        - indexPath: The index path of the selected cell.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check if cell, current labels and delegate exist
        guard let cell = tableView.cellForRow(at: indexPath), let currentLabels, let delegate else {
            return
        }
        // Update cell appearance
        cell.accessoryType = .checkmark
        
        // Update selected labels
        currentLabels.selectedLabels.append(allLabels[indexPath.row])
        
        // Notify the delegate to update labels
        delegate.updateLabels()
    }
    
    /**
     Handles the deselection of a table view cell.
     
     - Parameters:
        - tableView: The table view where the cell was selected.
        - indexPath: The index path of the deselected cell.
     */
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Check if cell, current labels and delegate exist
        guard let cell = tableView.cellForRow(at: indexPath), let currentLabels, let delegate else {
            return
        }
        // Update cell appearance
        cell.accessoryType = .none
        
        // Update selected labels
        currentLabels.deselectLabel(labelName: allLabels[indexPath.row])
        
        // Notify the delegate to update labels
        delegate.updateLabels()
    }
    
    /**
     Adds label to list of labels.
     */
    @IBAction func addLabel(_ sender: Any) {
        displayAddLabelAlert()
        guard let delegate else {
            return
        }
        delegate.updateLabels()
    }
    
    /**
     Handles the editting style for a table view cell.
     
     - Parameters:
         - tableView: The table view containing the cell.
         - editingStyle: The editing style for the cell.
         - indexPath: The index path of the cell.
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Check if the editing style is delete
        if editingStyle == .delete{
            // Checks if the database controller is available
            guard let databaseController else {
                return
            }
            // Retrieve the label to delete
            let labelToDelete = allLabels[indexPath.row]
            
            // Deselect the label from the current labels
            currentLabels?.deselectLabel(labelName: labelToDelete)
            
            // Remove the label from the database
            let _ = databaseController.removeLabel(label: labelToDelete)
            
            // Reload the label table view.
            labelTableView.reloadData()
        }
    }
    
    /**
     Displays add label alert.
     */
    func displayAddLabelAlert() {
        let alertController = UIAlertController(title: "Add New Label", message: nil, preferredStyle: .alert)
        alertController.addTextField {(textField) in
            textField.placeholder = "Enter new label name..."
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak alertController] _ in
            guard let textFields = alertController?.textFields, let databaseController = self.databaseController else {
                return
            }
            
            if let newLabel = textFields[0].text {
                if let labelAdded = databaseController.addLabel(newLabel: newLabel), labelAdded {
                    self.labelTableView.reloadData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Handle when view controller will disappear.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let delegate else {
            return
        }
        databaseController?.removeListener(listener: self)
        delegate.updateLabels()
    }
    
    /**
     Handle when view controller will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
}
