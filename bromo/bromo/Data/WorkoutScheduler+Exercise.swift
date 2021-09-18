//
//  WorkoutScheduler+Exercise.swift
//  bromo
//
//  Created by Kevin Grogan on 12/24/20.
//

import Foundation
import SwiftUI
import Combine


public class WorkoutScheduler: ObservableObject {
    typealias ExerciseList = [Exercise]
    @Published var workoutSchedule: [Exercise] = []
    
    init(_ config: Configuration, _ filteredWords: Set<String> = Set()) {
        // Creates an list of exercises based on the workout type and week.
        let fullWorkoutName = [config.workout, config.week].joined(separator: " ")
        guard let fullWorkout = workouts[fullWorkoutName] else {
            print("WARNING: \(fullWorkoutName) is not a valid workout. Not creating a schedule.")
            return
        }
        var exercises = Dictionary<Int, Exercise>()
        let liftPicker = LiftPicker(filteredWords)
        for (workoutExerciseName, workoutExercise) in fullWorkout {
            let lift = liftPicker.pick(workoutExercise.category, workoutExercise.directionAndGroup)
            let exercise = Exercise(name: lift.name, setsAndReps: workoutExercise.setsAndReps, id: workoutExerciseName)
            exercises[workoutExercise.order] = exercise
            liftPicker.addFilteredWord(exercise.name)  // ensure that the exercise is not sampled again
        }
        
        let sortedKeys = exercises.keys.sorted()
        workoutSchedule = sortedKeys.map{exercises[$0]!}
    }
    
    func replaceExercise(_ exerciseID: String, _ config: Configuration, _ filteredWords: Set<String> = Set()) {
        let filteredWordSet = Set(filteredWords)
        let liftNameSet = Set(workoutSchedule.map{$0.name})
        let filteredWordAndLiftNames = filteredWordSet.union(liftNameSet)
        let currentExerciseIndex = workoutSchedule.firstIndex{$0.id == exerciseID}!
        let currentExercise = workoutSchedule[currentExerciseIndex]
        let currentLift = lifts.first{$0.name == currentExercise.name}!
        let lift = LiftPicker(filteredWordAndLiftNames).pick(currentLift.category, currentLift.directionAndGroup)
        workoutSchedule[currentExerciseIndex].name = lift.name
    }
    
    func getScheduledExerciseNameBy(id: String?) -> String {
        if let exercise = workoutSchedule.first(where: {$0.id == id}){
            return exercise.name
        }
        else {
            return ""
        }
    }
    
    func updateSchedule(with exercise: Exercise) {
        if let index = workoutSchedule.firstIndex(where: {$0.id == exercise.id}){
            workoutSchedule[index] = exercise
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
    public var id: String?
    public var weight: Int?
    public var date: Date?
    
    init(logItem: LogItem) {
        name = logItem.exercise ?? ""
        setsAndReps = Exercise.combine(sets: Int(logItem.sets), reps: Int(logItem.reps))
        weight = Int(logItem.weight)
        date = logItem.date ?? Date()
        id = nil
    }
    
    init(name: String, setsAndReps: String, id: String) {
        self.name = name
        self.setsAndReps = setsAndReps
        self.id = id
        weight = nil
        date = nil
    }
    
    enum CodingKeys: String, CodingKey {
           case name = "Exercise"
           case setsAndReps = "Sets and Reps"
           case id = "Type"
        }
     
    public var sets: Int {
        set{
            let reps = Exercise.split(setsAndReps: self.setsAndReps).reps
            self.setsAndReps = Exercise.combine(sets: newValue, reps: reps)
        }
        get {
            return Exercise.split(setsAndReps: self.setsAndReps).sets
        }
    }
    
    public var reps: Int {
        set{
            let sets = Exercise.split(setsAndReps: self.setsAndReps).sets
            self.setsAndReps = Exercise.combine(sets: sets, reps: newValue)
        }
        get {
            return Exercise.split(setsAndReps: self.setsAndReps).reps
        }
    }
    
    private static func split(setsAndReps: String) -> (sets: Int, reps: Int) {
        let split = setsAndReps.components(separatedBy: "x")
        let sets = Int(split.first ?? "0") ?? 0
        let reps = Int(split.last ?? "0") ?? 0
        return (sets: sets, reps: reps)
    }
    
    private static func combine(sets: Int, reps: Int) -> String {
        return "\(sets)x\(reps)"
    }
        
}
