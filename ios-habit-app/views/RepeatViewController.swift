//
//  RepeatViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 20/4/2023.
//

import UIKit

// Private properties
private let PAGE_DAILY = 0
private let PAGE_WEEKLY = 1
private let PAGE_MONTHLY = 2
private let SEGUE_MONTHLY = "monthlyRepeatSegue"
private let SEGUE_WEEKLY = "weeklyRepeatSegue"
private let SEGUE_DAILY = "dailyRepeatSegue"

/**
 View controller used to customise repeat settings for habit modification.
 */
class RepeatViewController: UIViewController, RepeatPageDelegate {
    // Outlets for different repeat type views.
    @IBOutlet weak var weeklyView: UIView!
    @IBOutlet weak var dailyView: UIView!
    @IBOutlet weak var monthlyView: UIView!
    
    // Repeat delegate
    var repeatDelegate: RepeatDelegate?
    // Repeat object that will be customised
    var repeatObject: Repeat?
    // Outlet for segmented control
    @IBOutlet weak var repeatSegmentedControl: UISegmentedControl!
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make sure delegate, repeatObject and repeatType is set up.
        guard let delegate = repeatDelegate,let repeatObject = delegate.currentRepeat, let repeatType = repeatObject.type  else {
            // if repeat object does not exist create a new Repeat object
            self.repeatObject = Repeat()
            goToPage(PAGE_DAILY)
            return
        }
        // if repeat object exists use Repeat object for information and navigate to respective view.
        self.repeatObject = repeatObject
        switch repeatType {
            case RepeatType.weekly:
                goToPage(PAGE_WEEKLY)
            case RepeatType.monthly:
                goToPage(PAGE_MONTHLY)
            default:
                goToPage(PAGE_DAILY)
        }
    }
    
    // Handle when segment control selected index changes.
    @IBAction func segmentChanged(_ sender: Any) {
        guard let segment = sender as? UISegmentedControl else {
            return
        }
        if segment.selectedSegmentIndex == PAGE_DAILY {
            goToPage(PAGE_DAILY)
        }
        else if segment.selectedSegmentIndex == PAGE_WEEKLY {
            goToPage(PAGE_WEEKLY)
        }
        else {
            goToPage(PAGE_MONTHLY)
        }
    }
    
    /**
     Used to navigate to specific page based on a provided `page` parameter.
     
     It hides the `dailyView`, `weeklyView` and `monthlyView` based on the selected page value.
     
     - Parameter page: The selected page index.
     */
    func goToPage(_ page: Int){
        dailyView.isHidden = true
        weeklyView.isHidden = true
        monthlyView.isHidden = true
        switch page{
            case PAGE_WEEKLY: weeklyView.isHidden = false
            case PAGE_MONTHLY: monthlyView.isHidden = false
            default: dailyView.isHidden = false
        }
        guard let repeatObject = repeatObject else {
            return
        }
        repeatObject.type = RepeatType(rawValue: page)
        repeatSegmentedControl.selectedSegmentIndex = page
    }
    
    
    // MARK: - Delegation
    func updateRepeat(_ repeatObject: Repeat) {
        self.repeatObject = repeatObject
    }
    
    
    // MARK: - Navigation

    // Preparing view controllers before performing segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
        if segue.identifier == SEGUE_DAILY {
            guard let destination = segue.destination as? DailyRepeatViewController else {
                return
            }
            destination.delegate = self
            
            guard let repeatObject = repeatObject else {
                return
            }
            for day in repeatObject.daysArray {
                destination.selectedRows.append(day)
            }
            destination.repeatObject = repeatObject
        }
        if segue.identifier == SEGUE_WEEKLY {
            guard let destination = segue.destination as? WeeklyRepeatViewController else {
                return
            }
            destination.delegate = self
            destination.repeatObject = self.repeatObject
        }
        if segue.identifier == SEGUE_MONTHLY {
            guard let destination = segue.destination as? MonthlyRepeatViewController else {
                return
            }
            destination.delegate = self
            destination.repeatObject = self.repeatObject
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let delegate = repeatDelegate else {
            return
        }
        delegate.updateRepeat()
    }

}
