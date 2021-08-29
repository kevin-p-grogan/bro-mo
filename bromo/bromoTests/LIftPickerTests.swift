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
}
