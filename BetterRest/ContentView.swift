//
//  ContentView.swift
//  BetterRest
//
//  Created by Raouf on 31/01/2024.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0 
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? .now
    }
    
    
    var body: some View {
        
        NavigationStack{
            ZStack {
                
                RadialGradient(stops: [
                    .init(color: .red, location: 0.3),
                    .init(color: .blue, location: 0.3),
                ], center: .top, startRadius: 100, endRadius: 700)
                    .ignoresSafeArea()
                
                Form {
                    Section("When do you want to wake up?") {
                        DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .onChange(of: wakeUp, calculateBedtime)
                    }
                    .font(.headline)
                    
                    Section("Desired amount of sleep") {
                        Stepper("\(sleepAmount.formatted()) ", value: $sleepAmount, in: 4...12, step: 0.25)
                            .onChange(of: sleepAmount, calculateBedtime)
                    }
                    .font(.headline)
                    
                    Section("Daily coffee intake") {
                        Picker("Number of cups", selection: $coffeeAmount) {
                            ForEach(0..<11) {
                                Text($0, format: .number)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: coffeeAmount, calculateBedtime)
                    }
                    
                    
                    Section("Your ideal bedtime is") {
                        // showing the result
                        Text("\(alertTitle)")
                    }
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    
                    
                }
                .font(.headline)
                .navigationTitle("BetterRest")
                .onAppear {
                    calculateBedtime()
                }
            }
        }
        
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(hour + minute), estimatedSleep: sleepAmount, coffee: Int64(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "\(sleepTime.formatted(date: .omitted, time: .shortened))"
        } catch {
            alertTitle = "Error, Sorry, there was a problem calculating your bedtime."
        }
    }
}

#Preview {
    ContentView()
}
