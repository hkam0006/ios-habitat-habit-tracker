//
//  TimerSwiftUIView.swift
//  ios-habit-app
//
//  Created by Soodles . on 30/4/2023.
//
// Acknowledgements:
// Timer SwiftUI Tutorial by Indently (YouTube)
// Utilised this tutorial to learn about SwiftUI states and how to update the shapes with a Timer object. https://www.youtube.com/watch?v=NAsQCNpodPI&t=881s&ab_channel=Indently
// 

import SwiftUI

/**
 A SwiftUI view for displaying a timer for a habit.
 */
struct TimerSwiftUIView: View {
    // State properties manage the state of the timer.
    @State var countUpTimer = 0
    @State var timerRunning = false
    let habit: Habit
    let theme: CGColor
    @State var elapsedTime: Int
    @State var totalTime: Int
    // Creates a timer that publishes every second and updates the view.
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var remainingTime: Int {totalTime - elapsedTime}
    let animation = Animation.linear
    let date: Date
    
    private var habitName: String {
        habit.name ?? "Habit Name"
    }
    
    // many layout and content of the timer view.
    var body: some View {
        // Creates a background shape and applies the theme colour.
        ZStack{
            RoundedRectangle(cornerRadius: 16.0)
                .fill(Color(theme))
                .opacity(9.0)
            // vertical stack that contains the content of the timer view
            VStack(spacing: 10) {
                // Black circle
                Circle()
                    .strokeBorder(Color.black ,lineWidth: 24)
                    .frame(height: 400)
                    .overlay{
                        VStack{
                            Text("Current Habit:")
                                .foregroundColor(Color.black)
                            Text(habitName)
                                .font(.title)
                                .foregroundColor(Color.black)
                            Text("\(remainingTime.toTimeComponents().0):\(remainingTime.toTimeComponents().1):\(remainingTime.toTimeComponents().2)")
                                .foregroundColor(Color.black)
                        }
                        .accessibilityElement(children: .combine)
                    }
                    // Overlay circle with progress bar
                    .overlay {
                        HabitProgressArc()
                            .trim(from: 0.0, to: Double(elapsedTime)/Double(totalTime))
                            .rotation(Angle(degrees: -90))
                            .stroke(Color(theme), lineWidth: 20)
                            .opacity(0.8)
                            .onReceive(timer){ _ in // Updates timer and habit progress when timer publishes a new value
                                if remainingTime != 0 && timerRunning {
                                    elapsedTime += 1
                                    habit.incrementTime(date: date)
                                }
                            }
                            .animation(.easeInOut(duration: 0.1), value: Double(elapsedTime)/Double(totalTime))
                    }
                    .padding() // Adds padding modifier to the entire view.
                HStack(spacing: 30){
                    Button(action: {
                        timerRunning = !timerRunning
                    }) {
                        if !timerRunning {
                            Image(systemName: "play")
                                .frame(width: 30, height: 30)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .padding(10)
                                .foregroundColor(Color.black)
                        } else {
                            Image(systemName: "pause")
                                .frame(width: 30, height: 30)
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .padding(10)
                                .foregroundColor(Color.black)
                        }
                        
                    }
                    Button(action: {
                        elapsedTime = 0
                        habit.resetProgress(date: date)
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .frame(width: 30, height: 30)
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .padding(10)
                            .foregroundColor(Color.black)
                    }
                }
            }
            
        }
        .padding()
    }
}

struct TimerSwiftUIView_Previews: PreviewProvider {
    static var currentHabit: Habit {
        // pass habit into here. some delegation or something
        let habit = Habit()
        let metric = Metric()
        metric.totalTime = 1200
        habit.metric = metric
        return habit
    }
    
    static var previews: some View {
        if let metric = currentHabit.metric, let totalTime = metric.totalTime  {
            TimerSwiftUIView(habit: currentHabit, theme: UIColor.systemOrange.cgColor, elapsedTime: 60, totalTime: totalTime, date: Date())
        }
    }
}
