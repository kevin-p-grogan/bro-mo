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
    @Published var workoutSchedule: [Exercise]
    
    init(config: Configuration) {
        workoutSchedule = WorkoutFetcher.createWorkoutSchedule(config.workout, config.week, config.filteredWords)
    }
    
    static private func createWorkoutSchedule(_ workout: String, _ week: String, _ filteredWords: [String]) -> ExerciseList {
        // Creates an list of exercises based on the workout type and week.
        let fullWorkoutName = [workout, week].joined(separator: " ")
        guard let fullWorkout = workouts[fullWorkoutName] else {return ExerciseList()}
        var exercises = Dictionary<Int, Exercise>()
        var filteredSubstrings = Set(filteredWords)
        for (workoutExerciseName, workoutExercise) in fullWorkout {
            let lift = pickLift(workoutExercise.category, workoutExercise.directionAndGroup, filteredSubstrings)
            let exercise = Exercise(name: lift.name, setsAndReps: workoutExercise.setsAndReps, id: workoutExerciseName)
            exercises[workoutExercise.order] = exercise
            filteredSubstrings.insert(exercise.name)  // ensure that the exercise is not sampled again
        }
        
        let sortedKeys = exercises.keys.sorted()
        return sortedKeys.map{exercises[$0]!}
    }
    
    func populateWorkoutSchedule(_ config: Configuration) {
        // Populates the workout schedule for the given workout and week.
        workoutSchedule = WorkoutFetcher.createWorkoutSchedule(config.workout, config.week, config.filteredWords)
    }
    
    func replaceExercise(_ exerciseID: String, _ config: Configuration) {
        let filteredSubstrings = Set(workoutSchedule.map{$0.name}).union(Set(config.filteredWords))
        let currentExerciseIndex = workoutSchedule.firstIndex{$0.id == exerciseID}!
        let currentExercise = workoutSchedule[currentExerciseIndex]
        let currentLift = lifts.first{$0.name == currentExercise.name}!
        let lift = WorkoutFetcher.pickLift(currentLift.category, currentLift.directionAndGroup, filteredSubstrings)
        workoutSchedule[currentExerciseIndex].name = lift.name
    }
    
    private static func pickLift(_ category: String, _ directionAndGroup: String,  _ filteredSubstrings: Set<String>) -> Lift {
        // Picks a lift from the constant lifts array via weighted random sample
        let filteredLifts = lifts.filter{
            let lift = $0
            return (category == lift.category)
                &&  (directionAndGroup == lift.directionAndGroup)
                &&  (!filteredSubstrings.contains{lift.name.lowercased().contains($0.lowercased())})
        }
        var samplingArray = [Lift]()
        filteredLifts.forEach{samplingArray.append(contentsOf: Array(repeating: $0, count: $0.rating))}
        // The behavior here is to ignore the filtered substrings if no lifts are found.
        return samplingArray.randomElement()
            ?? lifts.filter{(category == $0.category) && (directionAndGroup == $0.directionAndGroup)}.randomElement()!
    }
    
    func getScheduledExerciseNameBy(id: String) -> String {
        if let exercise = workoutSchedule.first(where: {$0.id == id}){
            return exercise.name
        }
        else {
            return ""
        }
    }
    
    private func filterWorkoutSchedule(_ filterWords: [String]) {
        workoutSchedule = workoutSchedule.filter{
            let exerciseName = $0.name
            return !filterWords.contains{
                exerciseName.contains($0)
            }
        }
    }
}

struct Exercise: Codable, Identifiable, Hashable {
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
