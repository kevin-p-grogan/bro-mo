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
                    LogItemView(logItem: li)
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

struct LogItemView: View{
    var logItem: LogItem
    var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(logItem.exercise ?? "")
                    .font(.headline)
                Text("\(logItem.sets)x\(logItem.reps)@\(logItem.weight)")
                    .font(.subheadline)
            }
            Spacer()
            Text(dateFormatter.string(from: logItem.date!))
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
