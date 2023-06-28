//
//  HabitDetailsViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 13/5/2023.
//

import UIKit
import SwiftUI

private let SEGUE_CHART = "chartViewSegue"
private let SEGUE_EDIT = "editHabitSegue"

/**
 View controller that display's habit information such as streaks and progress chart.
 */
class HabitDetailsViewController: UIViewController {
    // Database
    var databaseController: DatabaseProtocol?
    @IBOutlet weak var habitNameLabel: UILabel!
    // Habit
    var habit: Habit?
    @IBOutlet weak var resetProgressButton: UIButton!
    // The chart view controller.
    var chartView: ChartViewController?
    // List of habits.
    var habitList: [Habit]?
    @IBOutlet weak var currentStreakLabel: UILabel!
    // habit streak object that calculates habit streaks.
    var habitStreak: HabitStreak?
    // Selected date.
    var selectedDate: Date?
    @IBOutlet weak var habitColourPreview: UIView!
    @IBOutlet weak var habitIconLabel: UILabel!
    @IBOutlet weak var habitStreakIcon: UIImageView!
    @IBOutlet weak var chartDataLabel: UILabel!
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHabitDetailsViewController()
    }
    
    // Updates the chart data label
    func updateChartLabel(label: String){
        chartDataLabel.text = label
    }
    
    func setupHabitDetailsViewController(){
        guard let habit = habit, let selectedDate else {
            return
        }
        
        habitStreak = HabitStreak(habit: habit, date: selectedDate)
        resetProgressButton.tintColor = habit.getUIColour()
        
        habitNameLabel.text = habit.name
        if let red = habit.redComponent,let green = habit.greenComponent,let blue = habit.blueComponent, let alpha = habit.alphaComponent {
            let habitColour = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
            habitColourPreview.backgroundColor = habitColour
            habitStreakIcon.tintColor = habitColour
        }
        habitIconLabel.text = habit.icon
        
        if let habitStreak, let repeatObj = habit.repeatObject {
            if repeatObj.type == .daily {
                currentStreakLabel.text = "\(habitStreak.currentStreak) day(s)"
            } else if repeatObj.type == .weekly {
                currentStreakLabel.text = "\(habitStreak.currentStreak) week(s)"
            } else {
                currentStreakLabel.text = "\(habitStreak.currentStreak) month(s)"
            }
        }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    // Method that resets the current selected date's progress for the habit.
    @IBAction func resetHabitProgress(_ sender: Any) {
        guard let habit, let selectedDate, let chartView, let habitList else {
            return
        }
        habit.resetProgress(date: selectedDate)
        chartView.habitStreak = HabitStreak(habit: habit, date: selectedDate)
        chartView.setupInitialView(colour: habit.getUIColour()!)
        
        // Update habits
        let _ = databaseController?.updateHabits(habits: habitList)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Setting up ChartViewController before performing segue
        if segue.identifier == SEGUE_CHART{
            if let destination = segue.destination as? ChartViewController{
                guard let habit, let selectedDate else {
                    return
                }
                destination.habitStreak = HabitStreak(habit: habit, date: selectedDate)
                destination.delegate = self
                if let red = habit.redComponent,let green = habit.greenComponent,let blue = habit.blueComponent, let alpha = habit.alphaComponent {
                    destination.colour = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
                }
                chartView = destination
            }
        }
        // Setting up EditHabitViewController before
        if segue.identifier == SEGUE_EDIT {
            if let destination = segue.destination as? EditHabitViewController{
                guard let habit else {
                    return
                }
                destination.habitList = habitList
                destination.habit = habit
            }
        }
    }
    
    // Update view controller.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupHabitDetailsViewController()
        if let chartView, let colour = habit?.getUIColour() {
            chartView.setupInitialView(colour: colour)
        }
    }
}
