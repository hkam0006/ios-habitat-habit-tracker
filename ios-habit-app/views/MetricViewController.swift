//
//  MetricViewController.swift
//  ios-habit-app
//
//  Created by Soodles . on 22/4/2023.
//

import UIKit


private let SEGUE_TIMED = "timedMetricSegue"
private let SEGUE_FREQUENCY = "frequencyMetricSegue"
private let PAGE_TIMED = 0
private let PAGE_FREQ = 1


/**
 A view controller for metric customisation for habit modification.
 */
class MetricViewController: UIViewController, MetricDelegate {
    // Segmented Control outlet
    @IBOutlet weak var metricTypeSegmentControl: UISegmentedControl!
    // UIView outlets.
    @IBOutlet weak var timedMetricView: UIView!
    @IBOutlet weak var frequencyMetricView: UIView!
    
    // Metric delegate
    var delegate: MetricDelegate?
    // Current metric object.
    var currentMetric: Metric?
    
    // Set up view controller according to current metric.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        guard let currentMetric else {
            return
        }
        // Switch to page according to the current metric settings.
        switch currentMetric.type{
        case .frequency:
            goToPage(PAGE_FREQ)
        default:
            goToPage(PAGE_TIMED)
        }
    }
    
    /**
     Handle view navigation when segmeneted control index changes.
     
     - Parameter sender: The segment control that triggered the action.
     */
    @IBAction func segmentChanged(_ sender: Any) {
        if metricTypeSegmentControl.selectedSegmentIndex == PAGE_TIMED{
            goToPage(PAGE_TIMED)
        } else {
            goToPage(PAGE_FREQ)
        }
    }
    
    func updateMetric() {
        // do nothing
    }
    
    /**
     Navigates to the specified page given the page index.
     
     - Parameter page: The index of the page to navigate to.
     - Note: The function updates the UI elements based on the selected page, including hiding/showing certain views and setting the metric type.
     */
    func goToPage(_ page: Int){
        guard let currentMetric else {
            return
        }
        // Navigate to timed-based metric habit settings
        if page == PAGE_TIMED {
            frequencyMetricView.isHidden = true
            timedMetricView.isHidden = false
            metricTypeSegmentControl.selectedSegmentIndex = 0
        }
        // Navigate to frequency-based metric habit settings
        else {
            frequencyMetricView.isHidden = false
            timedMetricView.isHidden = true
            currentMetric.type = .frequency
            metricTypeSegmentControl.selectedSegmentIndex = 1
        }
        // Setting the metric type.
        currentMetric.type = MetricType(rawValue: page)!
    }
    // MARK: - Navigation
    
    /**
     Set up before performing segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Performing timed-based metric segue
        if segue.identifier == SEGUE_TIMED {
            guard let destination = segue.destination as? TimedMetricViewController else {
                return
            }
            destination.delegate = self
            destination.currentMetric = currentMetric
        }
        // Performing frequency-based metric segue
        if segue.identifier == SEGUE_FREQUENCY{
            guard let destination = segue.destination as? FrequencyMetricViewController else {
                return
            }
            destination.delegate = self
            destination.currentMetric = currentMetric
        }
    }
    
    /**
     Handle when view controller disappears.
     */
    override func viewWillDisappear(_ animated: Bool) {
        guard let delegate else {
            return
        }
        delegate.updateMetric()
    }
}
