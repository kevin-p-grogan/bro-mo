//
//  LiftPicker.swift
//  bromo
//
//  Created by Kevin Grogan on 7/11/21.
//

import Foundation
import NaturalLanguage

public class LiftPicker {
    private var filteredWords: Set<String>  // Words provided by the user that are actively filtered
    private var sampleWeights: [Lift: Double]
    
    init(_ rawFilteredWords: Set<String> = Set(), lifts: [Lift] = lifts) {
        filteredWords = Set(rawFilteredWords.map(LiftPicker.regularize))
        sampleWeights = LiftPicker.computeSampleWeights(from: lifts)
    }
    
    private static func regularize(_ word: String) -> String {
        return word.lowercased()
    }
        
    static private func computeSampleWeights(from lifts: [Lift]) -> [Lift: Double] {
        // computation of the sample weights is only performed once here
        let logProbabilities = LiftPicker.computeLogProbabilities(from: lifts)
        let ratings = lifts.map{Double($0.rating)}
        let sampleWeightValues = zip(ratings, logProbabilities).map{$0.0 - $0.1}
        return Dictionary(uniqueKeysWithValues: zip(lifts, sampleWeightValues))
    }
    
    static private func computeLogProbabilities(from lifts: [Lift]) -> [Double] {
        let tolkenizedLiftNames: [[String]] = lifts.map{extractLiftTokens(using: $0)}
        let tokens = tolkenizedLiftNames.flatMap{$0}
        let counts = countOccurences(of: tokens)
        // Split these operations for efficiency since the number of tokens total is expected to be far greater than that found in the lift.
        let emptyLiftLogProbability = computeEmptyTokenLogProbability(with: counts)
        let logProbabilityCorrections: [Double] = tolkenizedLiftNames.map{computeLogProbabilityCorrection(using: $0, referencing: counts)}
        let logProbabilities = logProbabilityCorrections.map{emptyLiftLogProbability + $0}
        return logProbabilities
    }
    
    static private func extractLiftTokens(using lift: Lift) -> [String] {
        let liftName = lift.name
        let tolkenizer = NLTokenizer(unit: .word)
        tolkenizer.string = liftName
        let tokens = tolkenizer.tokens(for: liftName.startIndex ..< liftName.endIndex).map{String(liftName[$0])}
        let regularizedTokens = tokens.map(LiftPicker.regularize)
        let tokensWithoutStopWords = regularizedTokens.filter{!stopWords.contains($0)}
        return tokensWithoutStopWords
    }
    
    static private func countOccurences(of strings: [String]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for s in strings {
            if let currentCount = counts[s] {
                counts[s] = currentCount + 1
            }
            else{
                counts[s] = 1
            }
        }
        return counts
    }
    
    static private func computeEmptyTokenLogProbability(with counts: [String: Int]) -> Double {
        // Computes the log probability of the tokens being empty.
        let numTokens = counts.values.reduce(0, +)
        let emptyTokenLogProbability = counts.map{
            let probabilityTokenNotOccuring = 1.0 - Double($0.value)/Double(numTokens+1)  // add smoothing
            return log(probabilityTokenNotOccuring)
        }.reduce(0.0, +)
        return emptyTokenLogProbability
    }
    
    static private func computeLogProbabilityCorrection(using tokens: [String], referencing counts: [String: Int]) -> Double {
        // Computes the correction to the probabilty of "tokens" being an empty set.
        let numTokens = counts.values.reduce(0, +)
        let tokenLogProbabilityCorrections: [Double] = tokens.map{
            let token = $0
            let count = counts[token] ?? numTokens
            let tokenLogProbability = log(Double(count) / Double(numTokens+1))
            let noTokenLogProbility = log(1.0 - Double(count) / Double(numTokens+1))
            return tokenLogProbability - noTokenLogProbility
        }
        let logProbabiltyCorrection = tokenLogProbabilityCorrections.reduce(0.0, +)
        return logProbabiltyCorrection
    }
    
    func pick(_ category: String, _ directionAndGroup: String) -> Lift {
        // Picks a lift from the constant lifts array via weighted random sample
        let filteredLifts = Set(
            lifts.filter{
                let lift = $0
                return (category == lift.category)
                    &&  (directionAndGroup == lift.directionAndGroup)
                    && (!containsFilteredWord(lift))
            }
        )
        return sample(filteredLifts) ?? Lift("Error picking lift")
    }
    
    private func containsFilteredWord(_ lift: Lift) -> Bool {
        // Check that the name of the lift does not contain any of the filter substrings
        let liftName = LiftPicker.regularize(lift.name)
        for filteredWord in filteredWords {
            if liftName.contains(filteredWord) { return true }
        }
        return false
    }
    
    func sample(_ lifts: Set<Lift>) -> Optional<Lift> {
        let filteredSampleWeights: [Lift: Double] = sampleWeights.filter{lifts.contains($0.key)}
        var cumulativeSampleWeights: [Double] = []
        var runningTotal = 0.0
        for sampleWeight in filteredSampleWeights.values {
            runningTotal += sampleWeight
            cumulativeSampleWeights.append(runningTotal)
        }
        var selectedLift = filteredSampleWeights.keys.randomElement()
        if let cumlativeMax = cumulativeSampleWeights.max() {
            let randomNumber = Double.random(in: 0.0 ..< cumlativeMax)
            for (idx, lift) in filteredSampleWeights.keys.enumerated() { // linear search
                if cumulativeSampleWeights[idx] > randomNumber {
                    selectedLift = lift
                    break
                }
            }
        }
        else {
            print("WARNING: Weighted sampling failed. Returning a random lift.")
        }
        return selectedLift
    }
    
    func addFilteredWord(_ rawFilteredWord: String) {
        self.filteredWords.insert(LiftPicker.regularize(rawFilteredWord))
    }
}
