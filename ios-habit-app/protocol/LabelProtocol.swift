//
//  LabelProtocol.swift
//  ios-habit-app
//
//  Created by Soodles . on 22/4/2023.
//

import Foundation
/**
 Class representing the labels object used for habit categorisation.
 
 Each `Habit` class contains a `Labels` class that stores information of selected labels for a particular habit.
 */
class Labels: NSObject, Codable {
    // An array of strings that represent the selected labels for a habit.
    var selectedLabels: [String] = []
    
    private enum CodingKeys: String, CodingKey {
        case selectedLabels
    }
    
    /**
     Selects a label by adding it to the `selectedLabels` variable
     
     This method is used to select a label by adding it to the list of selected labels. If the label is not already present in the list, it is appended to the end of the list.
     
     - Parameters:
        - labelName: The name of the label to be selected.
     */
    func selectLabel(labelName: String){
        if !selectedLabels.contains(labelName) {
            selectedLabels.append(labelName)
        }
    }
    
    /**
     Deselects a label by remove it to the `selectedLabels` variable
     
     This method is used to deselect a label by removing it from the list of selected labels. All labels with the same name of the label will be removed from the list.
     
     - Parameters:
        - labelName: The name of the label to be deselected.
     */
    func deselectLabel(labelName: String){
        if selectedLabels.contains(labelName) {
            selectedLabels.removeAll{(label) in
                if label == labelName {
                    return true
                } else {
                    return false
                }
            }
        }
    }
    
    /**
     Creates a copy of the `Labels` object.
     
     - Returns: A new instance of the `Labels` class with the same property values as the original object.
     */
    func copy() -> Labels {
        let newLabels = Labels()
        newLabels.selectedLabels = self.selectedLabels
        return newLabels
    }
}

/**
 Protocol that defines methods that need to implemented for classes that ineherit the `MetricDelegate` protocol.
 */
protocol LabelDelegate {
    // Current labels associated with adopting class
    var currentLabels: Labels? {get set}
    
    /**
     Updates the label associated with adopting class
     
     This method is called to update the labels associated with the adopting class. It should be implemented by the conforming class to perform necessary updates or calculations related to the `Labels` class.
     */
    func updateLabels()
}
