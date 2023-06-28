//
//  MetricProtocol.swift
//  ios-habit-app
//
//  Created by Soodles . on 22/4/2023.
//

import Foundation

/**
 Protocol that defines methods that need to implemented for classes that inherit the `MetricDelegate` protocol.
 */
protocol MetricDelegate {
    // Current metric associated with the adopting class.
    var currentMetric: Metric? {get set}
    
    /**
     Updates the metric associated with the adopting class
     
     This method is called to update the metric associated with the adopting class. It should be implemented by the conforming class to perform any necessary updates or calculations related to the metric.
     */
    func updateMetric()
}

/**
 A enumeration that represents different types of metric.
 
 The `MetricType` enumeration defines two types of metrics, timed and frequency habit's metric based on their purpose or measurement method.
 */
enum MetricType: Int {
    case timed = 0
    case frequency = 1
}

/**
 A class representing a metric used for habit tracking.
 
 The `Metric` class stores information related to a specific metric, such as the total frequency, total time, and metric type. It conforms to the `Codable` protocol for easy encoding and decoding, and provides a `copy()` method for creating a copy of the metric object.
 */
class Metric: NSObject, Codable {
    // Total frequency of frequency based metric
    var totalFrequency: Int?
    
    // Total time of a timed based metric
    var totalTime: Int?
    
    // Type of metric
    var metricType: Int?
    
    private enum CodingKeys: String, CodingKey {
        case totalFrequency
        case totalTime
        case metricType
    }
    
    /**
     Creates a copy of the `Metric` object.
     
     - Returns: A new instance of the `Metric` class with the same property values as the original object.
     */
    func copy() -> Metric {
        let newMetric = Metric()
        newMetric.metricType = metricType
        newMetric.totalTime = totalTime
        newMetric.totalFrequency = totalFrequency
        newMetric.metricType = metricType
        newMetric.type = type
        return newMetric
    }
}

extension Metric {
    /**
     The metric type based on the metricType property.
     
     This computed property provides a more convenient way to access and set the metric type as a `MetricType` enum value, based on the raw value of the `metricType` property.
     */
    var type: MetricType {
        get {
            return MetricType(rawValue: self.metricType!)!
        }
        set {
            self.metricType = newValue.rawValue
        }
    }
}
