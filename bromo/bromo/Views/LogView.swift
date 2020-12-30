//
//  LogView.swift
//  bromo
//
//  Created by Kevin Grogan on 12/23/20.
//

import SwiftUI

struct LogView: View {
    @State var editLogItem = false
    @State var currentLogItem: LogItem? = nil
    @Environment(\.managedObjectContext) private var context
    // Fetch request specifes the entities to fetch from the core data and how to arrange.
    @FetchRequest(entity: LogItem.entity(), sortDescriptors:[NSSortDescriptor(key: "date", ascending: false)]) var logItems: FetchedResults<LogItem>
    
    var body: some View {
        NavigationView{
            List {
                ForEach(logItems) { li in
                    ExerciseItemView(exercise: Exercise(logItem: li)).onTapGesture {
                        self.editLogItem = true
                        self.currentLogItem = li
                    }
                }.onDelete { indexSet in
                    indexSet.forEach{context.delete(logItems[$0])}
                    saveContext(context)
                }
            }.navigationBarTitle("Log")
        }.sheet(isPresented: $editLogItem){
            LogSheetView(currentLogItem: $currentLogItem)
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        }.onDisappear{
            saveContext(context)
        }
    }
}

struct LogSheetView: View {
    @Binding var currentLogItem: LogItem?
    @State var name: String = ""
    @State var sets: Int = 0
    @State var reps: Int = 0
    @State var weight: Int = 0
    // Fetch request specifes the entities to fetch from the core data and how to arrange.
    @FetchRequest(entity: LogItem.entity(), sortDescriptors:[]) var logItems: FetchedResults<LogItem>
    
    var body: some View {
        if let logItem = currentLogItem {
            ExerciseModifier(name: $name, sets: $sets, reps: $reps, weight: $weight).onAppear{
                name = logItem.exercise ?? ""
                sets = Int(logItem.sets)
                reps = Int(logItem.reps)
                weight = Int(logItem.weight)
            }.onDisappear{
                let keyValues: [String: Any] = ["sets": Int16(sets), "reps": Int16(reps), "weight": Int16(weight), "exercise": name]
                currentLogItem?.setValuesForKeys(keyValues)
            }
        }
    }
}


struct ExerciseItemView: View{
    var exercise: Exercise
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.headline)
                Text("\(exercise.sets)x\(exercise.reps)@\(exercise.weight ?? 0)")
                    .font(.subheadline)
            }
            Spacer()
            Text(dateFormatter.string(from: exercise.date ?? Date()))
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
