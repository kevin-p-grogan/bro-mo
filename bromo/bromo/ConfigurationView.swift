//
//  Configuration.swift
//  bromo
//
//  Created by Kevin Grogan on 10/18/20.
//

import SwiftUI

struct ConfigurationView: View {
    @ObservedObject var config: Configuration
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $config.week, label: Text("Week")) {
                        ForEach(Configuration.weeks, id:\.self) { week in
                            Text(week)
                        }
                    }
                }
                Section {
                    Picker("Body Group", selection: $config.bodyGroup) {
                        ForEach(Configuration.bodyGroups, id:\.self) { bg in
                            Text(bg)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                Section {
                    Picker("Movement Direction", selection: $config.movementDirection) {
                        ForEach(Configuration.movementDirections, id:\.self) { md in
                            Text(md)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
    }
}

class Configuration: ObservableObject {
    @Published var week = weeks[0]
    @Published var bodyGroup = bodyGroups[0]
    @Published var movementDirection = movementDirections[0]
    static let weeks = ["Recovery", "Hypertrophy", "Strength", "Test"]
    static let bodyGroups = ["Upper", "Lower"]
    static let movementDirections = ["Push", "Pull"]
    
    func getWorkoutType() -> String { return self.bodyGroup + " " + self.movementDirection }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView(config: Configuration())
    }
}
