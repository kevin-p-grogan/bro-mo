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


    var workout: String {
        get {
            return self.bodyGroup + " " + self.movementDirection
        }
    }
    // TODO: Make config initialization relative to log
    private static var referenceDate: Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: "2020-12-07")!
    }
    
    init() {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(Configuration.referenceDate)
        let currentWeekIndex = Int(timeInterval.weeks) % weeks.count
        let currentDayIndex = Int(timeInterval.days) % weeklyRoutine.count
        week = weeks[currentWeekIndex]
        bodyGroup = bodyGroups[weeklyRoutine[currentDayIndex].bodyGroupIndex]
        movementDirection = movementDirections[weeklyRoutine[currentDayIndex].movementDirectionIndex]
        filteredWords  = [String]()
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
