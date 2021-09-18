//
//  Lift.swift
//  bromo
//
//  Created by Kevin Grogan on 12/25/20.
//

import Foundation

let lifts: [Lift] = load("lifts.json")
let workouts: [String: [String: WorkoutExercise]] = load("workouts.json")
let weeks = ["Recovery", "Hypertrophy", "Strength", "Test"]
let bodyGroups = ["Upper", "Lower"]
let movementDirections = ["Push", "Pull"]
let weeklyRoutine = [ // mapping from the day of the week to the workout definition index
    (bodyGroupIndex: 0, movementDirectionIndex: 0),
    (bodyGroupIndex: 0, movementDirectionIndex: 0),
    (bodyGroupIndex: 1, movementDirectionIndex: 1),
    (bodyGroupIndex: 1, movementDirectionIndex: 1),
    (bodyGroupIndex: 0, movementDirectionIndex: 1),
    (bodyGroupIndex: 0, movementDirectionIndex: 1),
    (bodyGroupIndex: 1, movementDirectionIndex: 0),
]

struct Lift: Hashable, Codable {
    var name: String
    var rating: Int
    var equipment: [String]
    var category: String
    private var rawDirectionAndGroup: String?
    var directionAndGroup: String {
        set{
            rawDirectionAndGroup = newValue
        }
        get {
            // set to category to match the handling the Lift data
            return rawDirectionAndGroup ?? category
        }
    }
    
    init(_ name: String, rating: Int = 1) {
        // Simple initiation primarily intended for testing
        self.name = name
        self.rating = rating
        equipment = []
        category = ""
        directionAndGroup = ""
    }
    
    enum CodingKeys: String, CodingKey {
        // create a name map for the keys from the JSON file
        case name
        case rating
        case equipment
        case category
        case rawDirectionAndGroup = "direction_and_group"
    }
}

struct WorkoutExercise: Hashable, Codable {
    var category: String
    var order: Int
    var setsAndReps: String
    private var rawDirectionAndGroup: String?
    var directionAndGroup: String {
        set{
            rawDirectionAndGroup = newValue
        }
        get {
            // set to category to match the handling the Lift data
            return rawDirectionAndGroup ?? category
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case category
        case rawDirectionAndGroup = "direction_and_group"
        case order
        case setsAndReps = "sets and reps"
    }
}


func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}
