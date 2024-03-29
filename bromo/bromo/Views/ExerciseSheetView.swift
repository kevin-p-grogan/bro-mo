//
//  ExerciseSheetView.swift
//  bromo
//
//  Created by Kevin Grogan on 12/24/20.
//

import SwiftUI

struct ExerciseSheetView: View {
    @ObservedObject var scheduler: WorkoutScheduler
    @Binding var currentExercise: Exercise?
    @State var name: String = ""
    @State var sets: Int = 0
    @State var reps: Int = 0
    @State var weight: Int = 0
    
    var body: some View {
        if var exercise = currentExercise {
            VStack{
                ExerciseModifier(name: $name, sets: $sets, reps: $reps, weight: $weight)
                SaveButton(sets: sets, reps: reps, weight: weight, name: name)
            }.onAppear {
                name = exercise.name
                sets = exercise.sets
                reps = exercise.reps
                weight = exercise.weight ?? 0
            }.onDisappear{
                exercise.name = name
                exercise.sets = sets
                exercise.reps = reps
                exercise.weight = weight
                scheduler.updateSchedule(with: exercise)
            }.preferredColorScheme(.dark)
        }
        else {
            Text("Uh, oh Spaghetti-Os")
        }
    }
}

struct ExerciseModifier: View {
    @Binding var name: String
    @Binding var sets: Int
    @Binding var reps: Int
    @Binding var weight: Int
    
    var body: some View {
        VStack{
            TextEditor(text: $name)
                .font(.title2)
                .frame(width: 300, height: 100)
                .multilineTextAlignment(.center)
            HStack{
                SpinnerSelector(setValue: $sets, withTitle: "Sets", from: 0, to: 100)
                SpinnerSelector(setValue: $reps, withTitle: "Reps", from: 0, to: 100)
                SpinnerSelector(setValue: $weight, withTitle: "Weight", withUnit: "lbs", from: 0, to: 1000, by: 5)
            }
            .offset(y: 50)
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

struct SaveButton: View {
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
            Image(systemName: "externaldrive")
                .accentColor(.red)
                .font(.system(size: 30))
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
            ExerciseSheetView(scheduler: WorkoutScheduler(Configuration()), currentExercise: $currentExercise)
        }
    }
}
