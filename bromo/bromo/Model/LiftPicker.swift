//
//  LiftPicker.swift
//  bromo
//
//  Created by Kevin Grogan on 7/11/21.
//

import Foundation
import NaturalLanguage

public class LiftPicker {
    let tolkenizer = NLTokenizer(unit: .word)
    private var filteredWords: Set<String>  // Words provided by the user that are actively filtered
    
    init(_ rawFilteredWords: Set<String> = Set()) {
        filteredWords = Set(rawFilteredWords.map(LiftPicker.regularize))
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
        return sample(filteredLifts)
    }
    
    private func containsFilteredWord(_ lift: Lift) -> Bool {
        // Check that the name of the lift does not contain any of the filter substrings
        let liftName = LiftPicker.regularize(lift.name)
        for filteredWord in filteredWords {
            if liftName.contains(filteredWord) { return true }
        }
        return false
    }
    
    func sample(_ lifts: [Lift]) -> Lift {
        let tolkenizedLiftNames: [[String]] = lifts.map{
            let liftName = $0.name
            tolkenizer.string = liftName
            let tokens = tolkenizer.tokens(for: liftName.startIndex ..< liftName.endIndex).map{String(liftName[$0])}
            let regularizedTokens = tokens.map(LiftPicker.regularize)
            let tokensWithoutStopWords = regularizedTokens.filter{!stopWords.contains($0)}
            return tokensWithoutStopWords
        }
        var counts: [String: Int] = [:]
        let tokens = tolkenizedLiftNames.flatMap{$0}
        for token in tokens {
            if counts.keys.contains(token){
                counts[token] = counts[token]! + 1
            }
            else{
                counts[token] = 1
            }
        }
        let numTokens = tokens.count
        let emptyLiftLogProbability = counts.map{
            let probabilityTokenNotOccuring = 1.0 - Double($0.value)/Double(numTokens+1)  // add smoothing
            return log(probabilityTokenNotOccuring)
        }.reduce(0.0, +)
        let naiveLogProbabilities: [Double] = tolkenizedLiftNames.map{
            let tokens = $0
            let tokenLogProbabilityCorrections: [Double] = tokens.map{
                let count = counts[$0] ?? numTokens
                let tokenLogProbability = log(Double(count) / Double(numTokens+1))
                let noTokenLogProbility = log(1.0 - Double(count) / Double(numTokens+1))
                return tokenLogProbability - noTokenLogProbility
            }
            let naiveLogProbability =  emptyLiftLogProbability + tokenLogProbabilityCorrections.reduce(0.0, +)
            return naiveLogProbability
        }
        let ratings = lifts.map{Double($0.rating)}
        let sampleWeights = zip(ratings, naiveLogProbabilities).map{$0.0 - $0.1}
        var cumulativeSampleWeights: [Double] = []
        var runningTotal = 0.0
        for sampleWeight in sampleWeights {
            runningTotal += sampleWeight
            cumulativeSampleWeights.append(runningTotal)
        }
        let randomNumber = Double.random(in: 0.0 ..< cumulativeSampleWeights.max()!)
        for (idx, lift) in lifts.enumerated() { // linear search
            if cumulativeSampleWeights[idx] > randomNumber {return lift}
        }
        print("Weighted sampling failed returning a random lift.")
        return lifts.randomElement()!
    }
    
    func addFilteredWord(_ rawFilteredWord: String) {
        self.filteredWords.insert(LiftPicker.regularize(rawFilteredWord))
    }
    
}
