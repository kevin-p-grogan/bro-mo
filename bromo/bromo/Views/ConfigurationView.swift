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
                    DatePicker("Cycle Start Date", selection: $config.cycleStartDate, displayedComponents: .date)
                }
                Section {
                    Picker(selection: $config.week, label: Text("Week")) {
                        ForEach(weeks, id:\.self) { week in
                            Text(week)
                        }
                    }
                    Picker("Body Group", selection: $config.bodyGroup) {
                        ForEach(bodyGroups, id:\.self) { bg in
                            Text(bg)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                    Picker("Movement Direction", selection: $config.movementDirection) {
                        ForEach(movementDirections, id:\.self) { md in
                            Text(md)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                Section {
                    FilterView()
                }
            }.navigationBarTitle("Configure")
        }
    }
}

struct FilterView: View {
    @State var filteredWord: String = ""
    @State private var isEditing = false
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: FilteredItem.entity(), sortDescriptors:[NSSortDescriptor(key: "filteredWord", ascending: true)]) var filteredItems: FetchedResults<FilteredItem>
    
    var body: some View {
        TextField("Add Filtered Word", text: $filteredWord) { isEditing in
            self.isEditing = isEditing
        } onCommit: {
            let newItem = FilteredItem(context: context)
            newItem.filteredWord = filteredWord
            saveContext(context)
        }
        List{
            ForEach(filteredItems) { fi in
                Text(fi.filteredWord ?? "")
            }.onDelete{indexSet in
                indexSet.forEach{context.delete(filteredItems[$0])}
                saveContext(context)
            }
        }
    }
}

class Configuration: ObservableObject {
    @Published var week: String
    @Published var bodyGroup: String
    @Published var movementDirection: String
    @Published var filteredWords: [String]
    @Published var cycleStartDate: Date {
        didSet {
            UserDefaults.standard.set(cycleStartDate, forKey: "cycleStartDate")
            let workoutConfig = Configuration.getWorkoutConfig(cycleStartDate)
            week = workoutConfig.week
            bodyGroup = workoutConfig.bodyGroup
            movementDirection = workoutConfig.movmentDirection
        }
    }

    var workout: String {
        get {
            return self.bodyGroup + " " + self.movementDirection
        }
    }
    
    init() {
        let cycleStartDate: Date = UserDefaults.standard.object(forKey: "cycleStartDate") as? Date ?? Date()
        let workoutConfig = Configuration.getWorkoutConfig(cycleStartDate)
        week = workoutConfig.week
        bodyGroup = workoutConfig.bodyGroup
        movementDirection = workoutConfig.movmentDirection
        filteredWords  = [String]()
        self.cycleStartDate = cycleStartDate
    }
    
    static func getWorkoutConfig(_ cycleStartDate: Date) -> (week: String, bodyGroup: String, movmentDirection: String) {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(cycleStartDate)
        let currentWeekIndex = mod(Int(timeInterval.weeks), weeks.count)
        let currentDayIndex = mod(Int(timeInterval.days), weeklyRoutine.count)
        let week = weeks[currentWeekIndex]
        let bodyGroup = bodyGroups[weeklyRoutine[currentDayIndex].bodyGroupIndex]
        let movementDirection = movementDirections[weeklyRoutine[currentDayIndex].movementDirectionIndex]
        return (week: week, bodyGroup: bodyGroup, movmentDirection: movementDirection)
    }
    
    static private func mod(_ num: Int, _ base: Int) -> Int {
        var remainder = num % base
        if remainder < 0 {
            remainder += base
        }
        return remainder
    }
    
    
    func addFilteredWord(word: String) {
        if !filteredWords.contains(word) {
            filteredWords.append(word)
        }
    }
    
    func deleteFilteredWords(at offsets: IndexSet) {
        filteredWords.remove(atOffsets: offsets)
    }
}

extension TimeInterval {
    var days: Double {
        return self / (24 * 60 * 60)  // Number of seconds in a day
    }
    var weeks: Double {
        return self / (24 * 60 * 60 * 7)  // Number of seconds in a week
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView(config: Configuration())
    }
}
