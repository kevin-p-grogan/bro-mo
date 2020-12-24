//
//  ExerciseSheetView.swift
//  bromo
//
//  Created by Kevin Grogan on 12/24/20.
//

import SwiftUI

struct ExerciseSheetView: View {
    @ObservedObject var fetcher: WorkoutFetcher
    @ObservedObject var config: Configuration
    @Environment(\.managedObjectContext) var context
    @Binding var currentExercise: Exercise?
    @State var sets: Int = 0
    @State var reps: Int = 0
    @State var weight: Int = 0
    
    var body: some View {
        if let exercise = currentExercise {
            VStack{
                ResampleButton(fetcher: fetcher, config: config, exerciseId: exercise.id)
                Text(exercise.name).font(.title)
                HStack{
                    VStack{
                        Text("Sets")
                        Picker("Sets", selection: $sets) {
                            ForEach(0 ..< 100) {
                                Text("\($0)")
                            }
                        }.pickerStyle(WheelPickerStyle())
                        .offset(y:-100)
                    }
                    .frame(width: 100)
                    .clipped()
                    VStack{
                        Text("Reps")
                        Picker("Reps", selection: $reps) {
                            ForEach(0 ..< 100) {
                                Text("\($0)")
                            }
                        }.pickerStyle(WheelPickerStyle())
                        .offset(y:-100)
                    }
                    .frame(width: 100)
                    .clipped()
                    VStack{
                        Text("Weight")
                        Picker("Weight", selection: $weight) {
                            ForEach(0 ..< 200){
                                Text("\($0 * 5) lbs")
                            }
                        }.pickerStyle(WheelPickerStyle())
                        .offset(y:-100)
                    }
                    .frame(width: 100)
                    .clipped()
                }
                .offset(y: 50)
                SaveExerciseButton(sets: sets, reps: reps, weight: weight, name: exercise.name)
                    .environment(\.managedObjectContext, context)
            }.onAppear {
                sets = exercise.sets
                reps = exercise.reps
            }
        }
        else {
            Text("Uh, oh Spaghetti-Os")
        }
    }
}

struct ResampleButton: View {
    var fetcher: WorkoutFetcher
    var config: Configuration
    var exerciseId: String
    @Environment(\.managedObjectContext) var context
    
    var body: some View{
        Button(action: {
            self.fetcher.fetchExercise(exerciseId, config.getWorkoutType(), config.week)
        }) {
            Text("Resample")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(Color.yellow)
                .cornerRadius(40)
                .foregroundColor(.black)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.yellow, lineWidth: 5)
                )
                
        }
        .padding(10)
    }
}

struct SaveExerciseButton: View {
    var sets: Int
    var reps: Int
    var weight: Int
    var name: String
    @State private var showingAlert = false
    @Environment(\.managedObjectContext) var context
    
    var body: some View{
        Button(action: {
            let newLogItem = LogItem(context: context)
            newLogItem.sets = Int16(sets)
            newLogItem.reps = Int16(reps)
            newLogItem.weight = Int16(weight)
            newLogItem.exercise = name
            newLogItem.date = Date()
            do {
                try context.save()
            }
            catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            showingAlert = true
        }) {
            Text("Save Exercsise")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .background(Color.yellow)
                .cornerRadius(40)
                .foregroundColor(.black)
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 40)
                        .stroke(Color.yellow, lineWidth: 5)
                )
                
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("Exercise Saved!"), dismissButton: .default(Text("OK")))
        }
    }
}



struct ExerciseSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    struct PreviewWrapper: View {  // Used to set up the state for the view
        @State var currentExercise: Exercise? = Exercise(name: "Test Name", setsAndReps: "5X5", id: "Test Primary")
        var body: some View {
            ExerciseSheetView(fetcher: WorkoutFetcher(), config: Configuration(), currentExercise: $currentExercise)
        }
    }
}
