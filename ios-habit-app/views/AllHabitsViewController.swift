//
//  AllHabitsViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 25/4/2023.
//

import UIKit

private let SEGUE_NEW_HABIT = "newHabitSegue"
private let SEGUE_NAV = "navigationControllerSegue"
private let SEGUE_HABIT_DETAILS_NAV = "habitDetailNavigatorSegue"
private let CELL_HABIT = "habitCell"
private let CELL_CATEGORY = "labelCell"
private let CELL_ADD_CATEGORY = "addLabelCell"
private let SEGUE_TIMER = "timerSegue"
private let SEGUE_HABIT_DETAILS = "habitDetailsSegue"

/**
 View controller that displays all habits, allows filtering by category, and provides options for adding new habits and viewing habit details.
 
 This view controller conforms to various protocols: `UIViewController`, `UITableViewDelegate`, `UITableViewDataSource`, `UICollectionViewDelegate`, `UICollectionViewDataSource`, `NewHabitDelegate`, and `DatabaseListener`.
 */
class AllHabitsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate, UICollectionViewDataSource, NewHabitDelegate, DatabaseListener {
    
    // MARK: - Properties
    
    // Database listener
    var listenerType = ListenerType.all
    // Button to increment day.
    @IBOutlet weak var nextDayButton: UIButton!
    // Button to decrement day.
    @IBOutlet weak var previousDayButton: UIButton!
    // The list of all habits
    var allHabits: [Habit] = []
    // The list of all labels.
    var labelList: [String] = []
    // The list of habits for a particular date.
    var todayHabits: [Habit] = []
    // The index of the filter index
    var filterIndex: Int?
    // List of habits filtered by categories.
    var filteredHabits: [Habit] = []
    @IBOutlet weak var allHabitsTableView: UITableView!
    // The date label that displays the date of the current day.
    @IBOutlet weak var dateString: UILabel!
    // The current date
    var selectedDate = CalendarUtil().getStartOfDay(date: Date())
    // Add habit button
    @IBOutlet weak var addHabitButton: UIButton!
    // The collection view of labels/categories
    @IBOutlet weak var categoriesView: UICollectionView!
    // The activity indicator
    var indicator = UIActivityIndicatorView()
    // Database controller
    weak var databaseController: DatabaseProtocol?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        // Setup the activity indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.color = UIColor.black
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            // center horizontally
            indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
        super.viewDidLoad()
        // Getting databaseController from UIApplication
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // Setting up delegation
        allHabitsTableView.delegate = self
        allHabitsTableView.dataSource = self
        categoriesView.delegate = self
        categoriesView.dataSource = self
        categoriesView.showsHorizontalScrollIndicator = false
        categoriesView.allowsMultipleSelection = false
        categoriesView.allowsSelection = true
        addHabitButton.layer.cornerRadius = addHabitButton.bounds.width * 0.5
    }
    
    // MARK: - Database Listener Methods
    
    func onHabitsChange(change: DatabaseChange, habitList: [Habit]) {
        allHabits = habitList
        setUpTodayHabits()
        setUpDateString()
    }
    
    func onLabelChange(change: DatabaseChange, labelList: [String]) {
        self.labelList = labelList
        self.labelList.append("  +  ")
        categoriesView.reloadData()
    }
    
    func onFriendsChange(change: DatabaseChange, friendList: [Friend], friendActivity: [String], friendRequest: [Friend]) {
        if let _ = databaseController?.currentUser {
            DispatchQueue.main.async {
                self.addHabitButton.isEnabled = true
                self.nextDayButton.isEnabled = true
                self.previousDayButton.isEnabled = true
            }
        } else {
            DispatchQueue.main.async {
                self.addHabitButton.isEnabled = false
                self.nextDayButton.isEnabled = false
                self.previousDayButton.isEnabled = false
            }
        }
    }
    
    func onUserChange(change: DatabaseChange) {
        // do nothing
    }
    
    // MARK: - Helper methods
    /**
     Set ups date string according to the selected date.
     */
    func setUpDateString(){
        dateString.text = CalendarUtil().monthDayString(date: selectedDate)
    }
    
    /**
     Updates changes of the habit list to database controller.
     */
    func flushChangesToDatabase(){
        guard let databaseController else {
            return
        }
        let _ = databaseController.updateHabits(habits: allHabits)
    }
    
    /**
     Sets up all the habits for the current date.
     */
    func setUpTodayHabits(){
        todayHabits = []
        for habit in allHabits {
            if selectedDate >= habit.startDate!{
                if !habit.isDailyAndContainsWeekday(on: selectedDate) {
                    // do not append
                } else {
                    todayHabits.append(habit)
                }
            }
        }
        filterHabits()
        allHabitsTableView.reloadData()
    }
    
    /**
     Method that add habits to the habit list.
     */
    func addHabit(_ newHabit: Habit) {
        allHabits.append(newHabit)
        setUpTodayHabits()
    }
    
    /**
     Increment to the next day and setup habits.
     */
    @IBAction func nextDayButton(_ sender: Any) {
        selectedDate = CalendarUtil().nextDay(date: selectedDate)
        setUpDateString()
        setUpTodayHabits()
    }
    
    /**
     Decrement to the previous day and setup habits.
     */
    @IBAction func previousDayButton(_ sender: Any) {
        selectedDate = CalendarUtil().previousDay(date: selectedDate)
        setUpDateString()
        setUpTodayHabits()
    }
    
    /**
     Filter the habits of according to the selected categories/labels.
     */
    func filterHabits(){
        if let filterIndex {
            filteredHabits = []
            for habit in todayHabits {
                if let habitCategories = habit.categories {
                    if habitCategories.selectedLabels.contains(labelList[filterIndex]){
                        filteredHabits.append(habit)
                    }
                }
            }
        } else {
            filteredHabits = todayHabits
        }
        allHabitsTableView.reloadData()
    }
    
    /**
     Notify user's friend list of habit completion.
     */
    func notify(habitName: String, completionDate: String){
        guard let databaseController else {
            return
        }
        databaseController.notifyFriends(completionDate: completionDate, habitName: habitName)
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
                let labelAdded = databaseController.addLabel(newLabel: newLabel)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Collection view data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == labelList.count - 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ADD_CATEGORY, for: indexPath)
            cell.backgroundColor = UIColor.systemBlue
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_CATEGORY, for: indexPath) as! CategoryCollectionViewCell
            cell.categoryNameLabel.text = labelList[indexPath.row]
            if cell.isSelected {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.systemBlue.cgColor
            } else {
                cell.layer.borderWidth = 0
            }
            return cell
        }
    }
    
    /**
     Selected collection view cell styling and interaction
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // if add label button is tapped.
        if indexPath.row == labelList.count - 1 {
            displayAddLabelAlert()
        } else {
            // If filterIndex is not nil
            if let filterIndex {
                if let deselectCell = collectionView.cellForItem(at: IndexPath(item: filterIndex, section: 0)) as? CategoryCollectionViewCell {
                    deselectCell.isSelected = false
                    collectionView.reloadSections(IndexSet(integer: 0))
                    // If selected cell is already selected, deselect cell.
                    if filterIndex == indexPath.row {
                        self.filterIndex = nil
                        filterHabits()
                        return
                    }
                }
            }
            // Set selected filter index and set cell isSelected to true.
            if let  cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell{
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.systemBlue.cgColor
                filterIndex = indexPath.row
                cell.isSelected = true
            }
            // Filter habits according to filter index.
            filterHabits()
        }
    }
    
    // MARK: - Table view data source
    
    /**
     The number of rows in section. Each section will contain one habit cell.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /**
     The number of sections.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredHabits.count
    }
    
    /**
     Setting up table view cells
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Getting dequeueReusableCell from CELL_HABIT identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_HABIT, for: indexPath) as! HabitTableViewCell
        let habit = filteredHabits[indexPath.section]
        
        // Setting up the habit cell styling
        if let name = habit.name, let habitColour = habit.getUIColour(), let icon = habit.icon {
            cell.habitLabel.text = name
            cell.iconLabel.text = icon
            cell.habitDetailLabel.text = "Habit Details"
            cell.progressBar.color = habitColour
            cell.habitColourView.backgroundColor = habitColour
            cell.habit = habit
            cell.delegate = self
            cell.habitDetailLabel.text = habit.habitDetails
            cell.selectedDate = selectedDate
            // If habit has a metric settings set up.
            if let _ = habit.metric  {
                cell.progressBar.progress = CGFloat(habit.getProgressOnDate(date: selectedDate))
            }
        }
        // Set selection cell style to none
        cell.selectionStyle = .none
        return cell
    }
    
    /**
     Handle interaction when habit cell is selected.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let habitCell = allHabitsTableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: SEGUE_HABIT_DETAILS_NAV, sender: habitCell)
    }
    
    /**
     Setting the habit cell height
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    /**
     Setting the habit footer height. The seperation between habit cells
     */
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    /**
     Customising the footer view to a have clear background colour.
     */
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    // MARK: - Navigation

    // Set up view controller's before performing segues.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Setting up delegate before performing segue to NewHabitViewController.
        if segue.identifier == SEGUE_NAV {
            if let nav_controller = segue.destination as? UINavigationController {
                if let destination = nav_controller.topViewController as? NewHabitViewController {
                    destination.delegate = self
                }
            }
        }
        // Setting up delegate before performing segue to TimerViewController
        if segue.identifier == SEGUE_TIMER {
            if let habitCell = sender as? HabitTableViewCell {
                if let nav_controller = segue.destination as? UINavigationController {
                    if let destination = nav_controller.topViewController as? TimerViewController {
                        destination.habit = habitCell.habit
                        destination.cell = habitCell
                        destination.selectedDate = selectedDate
                        destination.delegate = self
                    }
                }
            }
        }
        // Setting up delegate before performing segue to HabitDetailsViewController
        if segue.identifier == SEGUE_HABIT_DETAILS_NAV {
            if let habitCell = sender as? HabitTableViewCell{
                if let navigationController = segue.destination as? UINavigationController {
                    if let destination = navigationController.topViewController as? HabitDetailsViewController {
                        destination.habit = habitCell.habit
                        destination.selectedDate = self.selectedDate
                        destination.habitList = allHabits
                    }
                }
            }
        }
    }
    
    /**
     Prepares the View Controller when view will appear.
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Adds self as a listener of the database.
        databaseController?.addListener(listener: self)
        selectedDate = CalendarUtil().getStartOfDay(date: Date())
        setUpDateString()
        setUpTodayHabits()
    }
    
    /**
     Removing database listener when view is not in the view port.
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

}
