//
//  ContentView.swift
//  bromo
//
//  Created by Kevin Grogan on 10/11/20.
//

import Foundation
import SwiftUI
import Combine

struct WorkoutGeneratorView: View {
    @State private var workoutIndex: Int = 0
    @State private var weekIndex: Int = 0
    @ObservedObject var fetcher = WorkoutFetcher()
    
    var body: some View {
        VStack {
            ConfigurationView(workoutIndex: $workoutIndex, weekIndex: $weekIndex)
            GenerationButton(fetcher: fetcher, workoutIndex: $workoutIndex, weekIndex: $weekIndex)
            ScheduleView(fetcher: fetcher, workoutIndex: $workoutIndex, weekIndex: $weekIndex)
            Spacer()
        }
        .preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)

    }
}

struct ConfigurationView: View {
    static let weeks = ["Recovery", "Hypertrophy", "Strength", "Test"]
    static let workouts = ["Upper Push", "Upper Pull", "Lower Push", "Lower Pull"]
    @Binding var workoutIndex: Int
    @Binding var weekIndex: Int
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $weekIndex, label: Text("Week")) {
                        ForEach(0 ..< ConfigurationView.weeks.count) {
                            Text(ConfigurationView.weeks[$0])
                        }
                    }
                }
                Section {
                    Picker(selection: $workoutIndex, label: Text("Workout Type")) {
                        ForEach(0 ..< ConfigurationView.workouts.count) {
                            Text(ConfigurationView.workouts[$0])
                        }
                    }
                }
            }
            .navigationBarTitle("Workout Generator", displayMode: .inline)
        }
        .frame(height: 270)
    }
}

struct GenerationButton: View {
    var fetcher: WorkoutFetcher
    @Binding var workoutIndex: Int
    @Binding var weekIndex: Int
    
    var body: some View{
        Button(action: {
            self.fetcher.fetchWorkout(ConfigurationView.workouts[workoutIndex], ConfigurationView.weeks[weekIndex])
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

public class WorkoutFetcher: ObservableObject {
    
    typealias ExerciseList = [Exercise]
    @Published var workoutSchedule = ExerciseList()
    @Published var isLoading = false
    let url = URL(string: "https://bro-science-prod.herokuapp.com/generate")!
    
    func fetchWorkout(_ workout: String, _ week: String) {
        let workoutParameters = GeneratorParameters(workout: workout, week: week)
        guard let request = createRequest(using: workoutParameters, at: url) else {return}
        setWorkout(using: request)
    }
    
    func fetchExercise(_ exerciseID: String, _ workout: String, _ week: String) {
        let workoutParameters = GeneratorParameters(workout: workout, week: week)
        guard let request = createRequest(using: workoutParameters, at: url) else {return}
        setWorkout(using: request, onlyExerciseID: exerciseID)
    }
    
    func createRequest(using parameters:GeneratorParameters, at url: URL) -> URLRequest? {
        let encoder = JSONEncoder()
        guard let uploadData = try? encoder.encode(parameters) else {return nil}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData
        return request
    }
    
    func setWorkout(using request: URLRequest, onlyExerciseID eid: String? = nil) {
        // insert json data to the request
        let session = URLSession.shared
        self.isLoading = true
        let task = session.dataTask(with: request) { (data, response, error) in
            if let d = data {
                let decoder = JSONDecoder()
                do {
                    let decodedLists = try decoder.decode(ExerciseList.self, from: d)
                    DispatchQueue.main.async {
                        if eid != nil {
                            let replacementExercise = decodedLists.first{$0.id==eid}
                            if let re = replacementExercise {
                                self.workoutSchedule = self.workoutSchedule.map{$0.id==eid ? re: $0}
                            }
                        }
                        else {
                            self.workoutSchedule = decodedLists
                        }
                        self.isLoading = false
                    }
                }
                catch {
                    print("Unexpected error: \(error).")
                }
            } else {
                print("Uh oh, spaghetti-os")
            }
        }
        
        task.resume()
    }
    
}

struct ScheduleView: View {
    @ObservedObject var fetcher: WorkoutFetcher
    @Binding var workoutIndex: Int
    @Binding var weekIndex: Int

    var body: some View {
        if fetcher.isLoading {
            Text("Loading...")
                .padding(10)
        }
        else {
            List(fetcher.workoutSchedule) { exercise in
                VStack (alignment: .leading) {
                    Text(exercise.name)
                    Text(exercise.setsAndReps)
                        .font(.system(size: 11))
                }
                .onTapGesture {
                    fetcher.fetchExercise(exercise.id, ConfigurationView.workouts[workoutIndex], ConfigurationView.weeks[weekIndex])
                }
            }
            
        }
    }
}

struct Exercise: Codable, Identifiable {
    public var name: String
    public var setsAndReps: String
    public var id: String
    
    enum CodingKeys: String, CodingKey {
           case name = "Exercise"
           case setsAndReps = "Sets and Reps"
           case id = "Type"
        }
}


struct GeneratorParameters: Codable {
    let workout: String
    let week: String
}


struct WorkoutGenerator_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutGeneratorView()
    }
}
