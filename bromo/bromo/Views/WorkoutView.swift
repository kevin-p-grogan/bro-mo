//
//  ContentView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/11/20.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var config: Configuration
    @ObservedObject var fetcher: WorkoutFetcher
    
    var body: some View {
        VStack {
//            GenerationButton(fetcher: fetcher, config: config)
            ScheduleView(fetcher: fetcher, config: config)
            Spacer()
        }
    }
}

struct GenerationButton: View {
    var fetcher: WorkoutFetcher
    var config: Configuration
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: FilteredItem.entity(), sortDescriptors:[]) var filteredItems: FetchedResults<FilteredItem>
    
    var body: some View{
        Button(action: {
            self.fetcher.populateWorkoutSchedule(config, filteredWords: filteredItems.map{$0.filteredWord ?? ""})
        }) {
            Text("Generate")
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



struct ScheduleView: View {
    @ObservedObject var fetcher: WorkoutFetcher
    @ObservedObject var config: Configuration
    @State var editExercise = false
    @State var currentExercise: Exercise? = nil
    @Environment(\.managedObjectContext) var context
    @FetchRequest(entity: FilteredItem.entity(), sortDescriptors:[]) var filteredItems: FetchedResults<FilteredItem>


    var body: some View {
        NavigationView{
            List {
                ForEach(fetcher.workoutSchedule) { exercise in
                    ExerciseItemView(exerciseItem: ExerciseItem(exercise: exercise)).onTapGesture {
                        self.editExercise = true
                        self.currentExercise = exercise
                    }
                }.onDelete { indexSet in
                    for index in indexSet {
                        let exerciseId = fetcher.workoutSchedule[index].id
                        fetcher.replaceExercise(exerciseId, config, filteredWords: filteredItems.map{$0.filteredWord ?? ""})
                    }
                }
            }.navigationBarTitle("Workout")
        }.sheet(isPresented: $editExercise){
            ExerciseSheetView(fetcher: fetcher, config: config, currentExercise: $currentExercise)
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        }
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        SaveButton(sets: 10, reps: 10, weight: 100, name: "asdf")
    }
}
