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
    @ObservedObject var config: Configuration
    @ObservedObject var fetcher = WorkoutFetcher()
    
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
            self.fetcher.fetchWorkout(config.getWorkoutType(), config.week)
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
    @ObservedObject var config: Configuration

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
                    fetcher.fetchExercise(exercise.id, config.getWorkoutType(), config.week)
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
        WorkoutGeneratorView(config: Configuration())
    }
}