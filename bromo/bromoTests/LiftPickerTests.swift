//
//  bromoTests.swift
//  bromoTests
//
//  Created by Kevin Grogan on 8/8/21.
//

import XCTest
@testable import bromo
class LiftPickerTests: XCTestCase {

    func testPickerGetsCorrectLift() throws {
        struct PickerParams: Hashable {
            var category: String
            var directionAndGroup: String
        }
        let liftPicker = LiftPicker()
        let params = Set(lifts.map{PickerParams(category: $0.category, directionAndGroup: $0.directionAndGroup)})
        for param in params {
            let pickedLift = liftPicker.pick(param.category, param.directionAndGroup)
            XCTAssertEqual(pickedLift.category, param.category)
            XCTAssertEqual(pickedLift.directionAndGroup, param.directionAndGroup)
        }
    }
    
    func testSamplesEqualizesTokenOccurences() {
        let testLifts = [
            Lift("The Test1, alpha"),
            Lift("An: Test2 beta"),
            Lift("Test2 with gamma!"),
            Lift("Test2 after omega"),
            Lift("Test2 within kappa?"),
            Lift("About Test2 or delta!"),
        ]
        let testLiftSet = Set(testLifts)
        let liftPicker = LiftPicker(lifts: testLifts)
        let numSamples = 10000
        let numTest1Samples = (0 ..< numSamples).map{_ in
            let sampledLift = liftPicker.sample(testLiftSet)!
            return sampledLift == testLifts[0] ? 1: 0
        }.reduce(0, +)
        let foundTest1SampleProbaility = Double(numTest1Samples) / Double(numSamples)
        let uniformTest1Probility = 1.0 / Double(testLifts.count)
        XCTAssertGreaterThanOrEqual(foundTest1SampleProbaility, uniformTest1Probility)
    }
}
