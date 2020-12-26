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
    
    func fetchWorkout(_ workout: String, _ week: String) {
        // Populates the workout schedule for the given workout and week.
        let fullWorkoutName = [workout, week].joined(separator: " ")
        guard let fullWorkout = workouts[fullWorkoutName] else {return}
        var exercises = Dictionary<Int, Exercise>()
        for (workoutExerciseName, workoutExercise) in fullWorkout {
            let excludedExerciseNames = Set(exercises.values.map{$0.name})
            let lift = pickLift(workoutExercise.category, workoutExercise.directionAndGroup, excludedExerciseNames)
            let exercise = Exercise(name: lift.name, setsAndReps: workoutExercise.setsAndReps, id: workoutExerciseName)
            exercises[workoutExercise.order] = exercise
        }
        
        let sortedKeys = exercises.keys.sorted()
        workoutSchedule = ExerciseList()
        sortedKeys.forEach{workoutSchedule.append(exercises[$0]!)}
    }
    
    func fetchExercise(_ exerciseID: String, _ workout: String, _ week: String) {
        let excludedExerciseNames = Set(workoutSchedule.map{$0.name})
        let currentExerciseIndex = workoutSchedule.firstIndex{$0.id == exerciseID}!
        let currentExercise = workoutSchedule[currentExerciseIndex]
        let currentLift = lifts.first{$0.name == currentExercise.name}!
        let lift = pickLift(currentLift.category, currentLift.directionAndGroup, excludedExerciseNames)
        workoutSchedule[currentExerciseIndex].name = lift.name
    }
    
    private func pickLift(_ category: String, _ directionAndGroup: String,  _ excludedExerciseNames: Set<String>) -> Lift {
        // Picks a lift from the constant lifts array via weighted random sample
        let filteredLifts = lifts.filter{
                (category == $0.category)
            &&  (directionAndGroup == $0.directionAndGroup)
            &&  (!excludedExerciseNames.contains($0.name))
        }
        var samplingArray = [Lift]()
        filteredLifts.forEach{samplingArray.append(contentsOf: Array(repeating: $0, count: $0.rating))}
        return samplingArray.randomElement() ?? lifts.randomElement()!
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
