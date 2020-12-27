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
                Text(fetcher.getScheduledExerciseNameBy(id: exercise.id)).font(.title)
                HStack{
                    SpinnerSelector(setValue: $sets, withTitle: "Sets", from: 0, to: 100)
                    SpinnerSelector(setValue: $reps, withTitle: "Reps", from: 0, to: 100)
                    SpinnerSelector(setValue: $weight, withTitle: "Weight", withUnit: "lbs", from: 0, to: 1000, by: 5)
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

struct SpinnerSelector: View {
    @Binding var setValue: Int
    var title: String
    var start: Int
    var finish: Int
    var increment: Int
    var unit: String
    
    init (setValue: Binding<Int>, withTitle: String, from: Int, to: Int) {
        self._setValue = setValue
        self.title = withTitle
        self.start = from
        self.finish = to
        self.increment = 1
        self.unit = ""
    }
    init (setValue: Binding<Int>, withTitle: String, withUnit: String, from: Int, to: Int, by: Int) {
        self._setValue = setValue
        self.title = withTitle
        self.start = from
        self.finish = to
        self.increment = by
        self.unit = withUnit
    }
    
    var body: some View {
        VStack{
            Text(title)
            Picker(title, selection: $setValue) {
                ForEach(start ..< finish){
                    if $0 % increment == 0 {
                        Text(["\($0)", unit].joined(separator: " "))
                    }
                }
            }.pickerStyle(WheelPickerStyle())
            .offset(y:-100)
        }
        .frame(width: 100)
        .clipped()
    }
}

struct ResampleButton: View {
    var fetcher: WorkoutFetcher
    var config: Configuration
    var exerciseId: String
    @Environment(\.managedObjectContext) var context
    
    var body: some View{
        Button(action: {
            self.fetcher.replaceExercise(exerciseId)
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
            _ = createLogItem(context, sets, reps, weight, name)
            saveContext(context)
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
        var config = Configuration()
        @State var currentExercise: Exercise? = Exercise(name: "Test Name", setsAndReps: "5X5", id: "Test Primary")
        
        var body: some View {
            ExerciseSheetView(fetcher: WorkoutFetcher(config: config), config: config, currentExercise: $currentExercise)
        }
    }
}
