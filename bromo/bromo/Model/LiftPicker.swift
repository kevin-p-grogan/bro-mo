//
//  LiftPicker.swift
//  bromo
//
//  Created by Kevin Grogan on 7/11/21.
//

import Foundation

public class LiftPicker {
    private var filteredWords: Set<String>  // Words provided by the user that are actively filtered
    
    init(_ rawFilteredWords: [String] = []) {
        let filteredWordsList = rawFilteredWords.map(LiftPicker.regularize)
        self.filteredWords = Set(filteredWordsList)
    }
    
    private static func regularize(_ word: String) -> String {
        return word.lowercased()
    }
    
    func pick(_ category: String, _ directionAndGroup: String) -> Lift {
        
        // Picks a lift from the constant lifts array via weighted random sample
        let filteredLifts = lifts.filter{
            let lift = $0
            return (category == lift.category)
                &&  (directionAndGroup == lift.directionAndGroup)
                && (!containsFilteredWord(lift))
        }
        var samplingArray = [Lift]()
        filteredLifts.forEach{samplingArray.append(contentsOf: Array(repeating: $0, count: $0.rating))}
        // The behavior here is to ignore the filtered substrings if no lifts are found.
        return samplingArray.randomElement()
            ?? lifts.filter{(category == $0.category) && (directionAndGroup == $0.directionAndGroup)}.randomElement()!
    }
    
    private func containsFilteredWord(_ lift: Lift) -> Bool {
        // Check that the name of the lift does not contain any of the filter substrings
        let liftName = LiftPicker.regularize(lift.name)
        for filteredWord in filteredWords {
            if liftName.contains(filteredWord) { return true }
        }
        return false
    }
    
    func addFilteredWord(_ rawFilteredWord: String) {
        self.filteredWords.insert(LiftPicker.regularize(rawFilteredWord))
    }
    
}
