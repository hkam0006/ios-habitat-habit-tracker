//
//  HabitTableViewCell.swift
//  ios-habit-app
//
//  Created by Soodles . on 18/4/2023.
//

import UIKit

/**
 Habit Table View cell utilised in `AllHabitsViewController`'s `UITableView`
 */
class HabitTableViewCell: UITableViewCell {
    var habit: Habit?
    var selectedDate: Date?
    @IBOutlet weak var actionButton: UIButton!
    var delegate: AllHabitsViewController?
    @IBOutlet weak var habitColourView: UIView!
    @IBOutlet weak var habitLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    @IBOutlet weak var habitDetailLabel: UILabel!
    @IBOutlet weak var progressBar: ProgressBarUIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        actionButton.setTitle( "Done", for: .disabled)
        actionButton.setImage( UIImage(), for: .disabled)
    }
    
    // Set up layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let habit,let selectedDate else {
            return
        }
        let progress = habit.getProgressOnDate(date: selectedDate)
        if progress >= 1.0 {
            setCellDisabled()
        } else {
            setCellEnabled()
        }
    }
    
    // Set up button according to habit type
    func setUpButtonType(){
        guard let habit, let selectedDate else {
            return
        }
        let progress = habit.getProgressOnDate(date: selectedDate)
        if progress >= 1.0 {
            setCellDisabled()
        } else {
            setCellEnabled()
        }
        
    }

    @IBAction func increaseProgress(_ sender: Any) {
        if habit?.metric?.type == .timed {
            guard let delegate else {
                return
            }
            delegate.performSegue(withIdentifier: "timerSegue", sender: self)
        } else {
            guard let habit,let habitName = habit.name, let selectedDate, let delegate else {
                return
            }
            habit.incrementFrequencyOn(date: selectedDate)
            progressBar.progress = CGFloat(habit.getProgressOnDate(date: selectedDate))
            if progressBar.progress >= 1.0 {
                setCellDisabled()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/YY"
                let dateString = dateFormatter.string(from: selectedDate)
                delegate.notify(habitName: habitName, completionDate: dateString)
            }
            delegate.flushChangesToDatabase()
        }
    }
    
    func setCellDisabled(){
        progressBar.progress = 1.0
        actionButton.layer.borderWidth = 0
        actionButton.isHidden = true
        self.layer.allowsGroupOpacity = true
        self.layer.opacity = 0.7
    }
    
    func setCellEnabled(){
        guard let habit = habit, let metric = habit.metric, let selectedDate else {
            return
        }
        if metric.type == .timed {
            self.actionButton.setTitle("Time", for: .normal)
            self.actionButton.setImage(UIImage(named: "timer"), for: .normal)
            self.progressBar.progress = CGFloat(habit.getProgressOnDate(date: selectedDate))
            self.actionButton.isHidden = false
        } else {
            self.actionButton.setTitle("Log", for: .normal)
            self.actionButton.setImage(UIImage(named: "plus"), for: .normal)
            self.actionButton.isHidden = false
        }
        self.actionButton.layer.borderWidth = 1
        self.actionButton.layer.borderColor = UIColor.systemBlue.cgColor
    }
    
    func updateProgressBar(){
        guard let habit, let metric = habit.metric, let habitName = habit.name, let selectedDate, let delegate else {
            return
        }
        if metric.type == .timed {
            let progress = habit.getProgressOnDate(date: selectedDate)
            progressBar.progress = CGFloat(progress)
            if progress >= 1.0 {
                setCellDisabled()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/YY"
                let dateString = dateFormatter.string(from: selectedDate)
                delegate.notify(habitName: habitName, completionDate: dateString)
            }
            delegate.flushChangesToDatabase()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    


}
