//
//  ContentView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/11/20.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var config: Configuration
    @ObservedObject var scheduler: WorkoutScheduler
    
    var body: some View {
        VStack {
            ScheduleView(scheduler: scheduler, config: config)
            Spacer()
        }
    }
}

struct ScheduleView: View {
    @ObservedObject var scheduler: WorkoutScheduler
    @ObservedObject var config: Configuration
    @State var editExercise = false
    @State var currentExercise: Exercise? = nil
    @FetchRequest(entity: FilteredItem.entity(), sortDescriptors:[]) var filteredItems: FetchedResults<FilteredItem>
    var filteredWords: Set<String> {
        get {
            return Set(filteredItems.map{$0.filteredWord ?? ""})
        }
    }

    var body: some View {
        NavigationView{
            List {
                ForEach(scheduler.workoutSchedule) { exercise in
                    ExerciseItemView(exercise: exercise).onTapGesture {
                        self.editExercise = true
                        self.currentExercise = exercise
                    }
                }.onDelete { indexSet in
                    for index in indexSet {
                        if let exerciseId = scheduler.workoutSchedule[index].id {
                            scheduler.replaceExercise(exerciseId, config, filteredWords)
                        }
                    }
                }
            }.navigationBarTitle("Workout")
        }.sheet(isPresented: $editExercise){
            ExerciseSheetView(scheduler: scheduler, currentExercise: $currentExercise)
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        SaveButton(sets: 10, reps: 10, weight: 100, name: "asdf")
    }
}
