//
//  ChartViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 14/5/2023.
//

import UIKit
import SwiftUI

/**
 View controller for hosting SwiftUI chart view
 */
class ChartViewController: UIViewController {
    var habitStreak: HabitStreak?
    var chartController: UIHostingController<ChartSwiftUIView>?
    var delegate: HabitDetailsViewController?
    var colour: UIColor?
    
    // Set up view controller on load.
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let colour else {
            return
        }
        setupInitialView(colour: colour)
    }
    
    /**
     Sets up the initial view with the provided colour.
     
     - Parameters:
        - colour: The colour to be used.
     */
    func setupInitialView(colour: UIColor){
        // Check if habit streak and delegate exist
        guard let habitStreak, let delegate else {
            return
        }
        // Create the charting data using the progress array from the habit streak
        let progressArray = habitStreak.getProgressArray()
        var chartingData = [HabitProgressDataProgress]()
        for progress in progressArray {
            chartingData.append(.init(progress: progress.1, date: progress.0))
        }
        // Create a UIHostingController with the ChartSwiftUIView as the rootView
        let controller = UIHostingController(rootView: ChartSwiftUIView(chartingData: chartingData,colour: colour, delegate: delegate))
        // check if the chart view is available.
        guard let chartView = controller.view else {
            return
        }
        
        // set the background colour of the view and chart view
        view.backgroundColor = UIColor(named: "AccentColour")
        chartView.backgroundColor = UIColor(named: "AccentColour")
        
        // Add the chart view as a subview and add the controller as a child
        view.addSubview(chartView)
        addChild(controller)
        
        // Set chartView's translatesAutoresizingMaskIntoConstraints to false to use auto layout
        chartView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up auto layout constrants for the chart view
        NSLayoutConstraint.activate([
            chartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5.0),
            chartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10.0),
            chartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5.0),
            chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0)
        ])
        
        // Set the chart controller and update the chart label with the average progress.
        chartController = controller
        if let chartView = chartController?.rootView as? ChartSwiftUIView {
            delegate.updateChartLabel(label: "Average: \(String(format: "%.0f", round(chartView.averageProgress() * 100)))%")
        }
    }
}
