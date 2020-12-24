//
//  LogView.swift
//  bromo
//
//  Created by Kevin Grogan on 12/23/20.
//

import SwiftUI

struct LogView: View {
    @Environment(\.managedObjectContext) private var context
    // Fetch requeest specifes the entities to fetch from the core data and how to arrange.
    @FetchRequest(entity: LogItem.entity(), sortDescriptors:[NSSortDescriptor(key: "date", ascending: false)]) var logItems: FetchedResults<LogItem>
    
    var body: some View {
        VStack{
            Text("Exercise Log").font(.title)
            List {
                ForEach(logItems) { li in
                    ExerciseItemView(exerciseItem: ExerciseItem(logItem: li))
                }.onDelete { indexSet in
                    for index in indexSet {
                        context.delete(logItems[index])
                    }
                    do {
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

struct ExerciseItemView: View{
    var exerciseItem: ExerciseItem
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(exerciseItem.exercise)
                    .font(.headline)
                Text("\(exerciseItem.sets)x\(exerciseItem.reps)@\(exerciseItem.weight)")
                    .font(.subheadline)
            }
            Spacer()
            Text(dateFormatter.string(from: exerciseItem.date))
        }
    }
}

struct ExerciseItem {
    // Adapter to unify displaying exercises without the overhead of managing the context
    var exercise: String
    var sets: Int
    var reps: Int
    var weight: Int
    var date: Date
    
    init(logItem: LogItem) {
        self.exercise = logItem.exercise ?? ""
        self.sets = Int(logItem.sets)
        self.reps = Int(logItem.reps)
        self.weight = Int(logItem.weight)
        self.date = logItem.date ?? Date()
    }
    
    init(exercise: Exercise) {
        self.exercise = exercise.name
        self.sets = exercise.sets
        self.reps = exercise.reps
        self.weight = 0
        self.date = Date()
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
