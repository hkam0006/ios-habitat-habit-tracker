//
//  HabitProgressArc.swift
//  ios-habit-app
//
//  Created by Soodles . on 30/4/2023.
//
// Acknowledgements:
// Habit Timer
// Followed Scrumdinger Meeting Timer tutorial provided by Apple at https://developer.apple.com/tutorials/app-dev-training/drawing-the-timer-view
// `path` function is similar to the tutorial code by altered to fit this application.

import Foundation
import SwiftUI
/**
The `HabitProgressArc` struct defines a custom shape that represents a circular progress arc. It conforms to the `Shape` protocol provided by SwiftUI, allowing it to be used as a view or a part of a view's hierarchy.
 */
struct HabitProgressArc: Shape {
    
    /**
     Defines the path of the progress arc within the given rectangle.
     
     This method is required to conform to the `Shape` protocol. It creates and returns a `Path` object representing a circular arc based on the provided rectangle.
     
     - Parameters:
        - rect: The rectangular area in which the progress arc should be drawn.
     - Returns: A `Path` object representing the progress arc.
     */
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 24
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { (path) in
            path.addArc(center: center, radius: radius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 360), clockwise: false)
        }
    }
}
