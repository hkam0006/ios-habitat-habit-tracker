//
//  ChartSwiftUIView.swift
//  ios-habit-app
//
//  Created by Soodles . on 14/5/2023.
//

import SwiftUI
import Charts

struct HabitProgressDataProgress: Identifiable {
    var progress: Float
    var date: String
    var id = UUID()
}

struct ChartSwiftUIView: View {
    // Data to be charted.
    let chartingData: [HabitProgressDataProgress]
    // The theme of the chart
    let colour: UIColor
    // The delegate
    let delegate: HabitDetailsViewController
    // State variable
    @State private var selectedDate: String?
    
    /**
     Finds the average progress value within the `chartingData` array.
     
     - Returns: The average progress value within the `chartingData` array.
     */
    func averageProgress() -> Float{
        var sum: Float = 0.0
        for data in chartingData {
            sum += data.progress
        }
        return sum / Float(chartingData.count)
    }
    
    /**
     Finds the progress value associated with the given date in the `chartingData` array.
     
     - Parameter date: A date string for which to find the progress value.
     - Returns: The progress value associated with the given date, or `nil` if no matching data is found
     */
    func findProgress(date: String) -> Float? {
        for data in chartingData{
            if data.date == date {
                return data.progress
            }
        }
        return nil
    }
    
    /**
     Updates the selected date based on the given location in the chart and provided `ChartProxy` instance.
     
     This function is called when the user interacts with the chart. It determines the data corresponding to the x-position in the chart and updates the `selectedDate` property.
     
     - Precondition: The `proxy` must contain valid data for retrieving the date value.
     - Postcondition: The `selectedDate` variable is updated.
     
     - Parameters:
        - location: The `CGPoint` representing location in the chart where the user interacted.
        - proxy: The `ChartProxy` instance used to retrieve the value at the specified x-position.
        - drag: A `Boolean` variable indicating whether the user is currently draggin or selecting a data point.
     */
    func updateSelectedDate(at location: CGPoint, proxy: ChartProxy, drag: Bool){
        // Get x-position
        let xPosition = location.x
        // Get date string from x-position
        guard let date: String = proxy.value(atX: xPosition, as: String.self) else {
            return
        }
        // If it is a tap interaction
        if !drag {
            // If date is already selected, we clear the selection.
            if selectedDate == date {
                selectedDate = nil
                // Notify delegate
                delegate.updateChartLabel(label: "Average: \(String(format: "%.0f", round(averageProgress() * 100)))%")
            }
            // If they are different, we set the selected date as the new selected date.
            else {
                selectedDate = date
                if let progress = findProgress(date: date){
                    // Notify delegate
                    delegate.updateChartLabel(label: "\(date): \(String(format: "%.0f", round(progress * 100)))%")
                }
            }
        }
        // If it is a drag interaction
        else {
            // update selectedDate with new selected date.
            selectedDate = date
            if let progress = findProgress(date: date){
                // Notify delegate
                delegate.updateChartLabel(label: "\(date): \(String(format: "%.0f", round(progress * 100)))%")
            }
        }
    }
    
    var body: some View {
        Chart {
            // Loop through charting data and plot bar chart.
            ForEach(chartingData) { habitData in
                let dateString = habitData.date
                BarMark(x: .value("Date", dateString),
                        y: .value("Progress", round(habitData.progress * 100)))
                .opacity(0.9)
            }
            // if selected date is not nil, plot bar mark.
            if let selectedDate {
                RectangleMark(x: .value("Date", selectedDate))
                    .foregroundStyle(.selection.opacity(0.4))
            }
            // if selected date is nil, plot RuleMark with average progress value.
            else {
                RuleMark(y: .value("Average", round(averageProgress() * 100)))
                    .foregroundStyle(Color(uiColor: UIColor.label))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3]))
            }
        }
        .foregroundColor( Color(uiColor: colour))
        // adds a overlay on the chart, provides a ChartProxy.
        .chartOverlay {(proxy) in
            Rectangle().fill(.clear).contentShape(Rectangle())
                .onTapGesture { location in
                    updateSelectedDate(at: location, proxy: proxy, drag: false)
                }
                .gesture(
                    DragGesture()
                        .onChanged {value in
                            let location = CGPoint(x:value.location.x, y: value.location.y)
                            updateSelectedDate(at: location, proxy: proxy, drag: true)
                        }
                )
        }
        .chartYAxis {
            AxisMarks(values: [0, 50, 100, round(averageProgress() * 100)]){
                let value = $0.as(Float.self)!
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    Text("\(String(format: "%.0f", value))%")
                }
            }
        }
    }   
}


