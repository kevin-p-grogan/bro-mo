//
//  WorkoutFetcher+Exercise.swift
//  bromo
//
//  Created by Kevin Grogan on 12/24/20.
//

import Foundation
import Combine


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

    private func setWorkout(using request: URLRequest, onlyExerciseID eid: String? = nil) {
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

struct Exercise: Codable, Identifiable {
    public var name: String
    public var setsAndReps: String
    public var id: String
    
    enum CodingKeys: String, CodingKey {
           case name = "Exercise"
           case setsAndReps = "Sets and Reps"
           case id = "Type"
        }
     
    public var sets: Int {
        set{
            let reps = convertSetsAndReps().reps
            self.setsAndReps = "\(newValue)x\(reps)"
        }
        get {
            return convertSetsAndReps().sets
        }
    }
    
    public var reps: Int {
        set{
            let sets = convertSetsAndReps().sets
            self.setsAndReps = "\(sets)x\(newValue)"
        }
        get {
            return convertSetsAndReps().reps
        }
    }
    
    private func convertSetsAndReps() -> (sets: Int, reps: Int) {
        let split = self.setsAndReps.components(separatedBy: "x")
        let sets = Int(split.first ?? "0") ?? 0
        let reps = Int(split.last ?? "0") ?? 0
        return (sets: sets, reps: reps)
    }
        
}

struct GeneratorParameters: Codable {
    let workout: String
    let week: String
}
