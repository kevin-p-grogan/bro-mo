//
//  LogView.swift
//  bromo
//
//  Created by Kevin Grogan on 12/23/20.
//

import SwiftUI

struct LogView: View {
    @Environment(\.managedObjectContext) private var context
    // Fetch request specifes the entities to fetch from the core data and how to arrange.
    @FetchRequest(entity: LogItem.entity(), sortDescriptors:[NSSortDescriptor(key: "date", ascending: false)]) var logItems: FetchedResults<LogItem>
    
    var body: some View {
        NavigationView{
            List {
                ForEach(logItems) { li in
                    ExerciseItemView(exercise: Exercise(logItem: li))
                }.onDelete { indexSet in
                    indexSet.forEach{context.delete(logItems[$0])}
                    saveContext(context)
                }
            }.navigationBarTitle("Log")
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

//struct ExerciseItem {
//    // Adapter to unify displaying exercises without the overhead of managing the context
//    var exercise: String
//    var sets: Int
//    var reps: Int
//    var weight: Int
//    var date: Date
//
//    init(logItem: LogItem) {
//        self.exercise = logItem.exercise ?? ""
//        self.sets = Int(logItem.sets)
//        self.reps = Int(logItem.reps)
//        self.weight = Int(logItem.weight)
//        self.date = logItem.date ?? Date()
//    }
//
//    init(exercise: Exercise) {
//        self.exercise = exercise.name
//        self.sets = exercise.sets
//        self.reps = exercise.reps
//        self.weight = exercise.weight ?? 0
//        self.date = Date()
//    }
//}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
