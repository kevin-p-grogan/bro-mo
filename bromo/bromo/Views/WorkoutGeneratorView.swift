//
//  ContentView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/11/20.
//

import SwiftUI

struct WorkoutGeneratorView: View {
    @ObservedObject var config: Configuration
    @ObservedObject var fetcher: WorkoutFetcher
    
    var body: some View {
        VStack {
            GenerationButton(fetcher: fetcher, config: config)
            ScheduleView(fetcher: fetcher, config: config)
            Spacer()
        }
    }
}

struct GenerationButton: View {
    var fetcher: WorkoutFetcher
    var config: Configuration
    
    var body: some View{
        Button(action: {
            self.fetcher.populateWorkoutSchedule(config)
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


    var body: some View {
        List(fetcher.workoutSchedule) { exercise in
            VStack (alignment: .leading) {
                ExerciseItemView(exerciseItem: ExerciseItem(exercise: exercise))
            }
            .onTapGesture {
                self.editExercise = true
                self.currentExercise = exercise
            }
        }.sheet(isPresented: $editExercise){
            ExerciseSheetView(fetcher: fetcher, config: config, currentExercise: $currentExercise)
                .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
        }
    }
}

struct WorkoutGenerator_Previews: PreviewProvider {
    static var previews: some View {
        SaveExerciseButton(sets: 10, reps: 10, weight: 100, name: "asdf")
    }
}
