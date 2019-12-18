//
//  MathOMatTests.swift
//  MathOMatTests
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import XCTest
@testable import MathOMat

class MathOMatTests: XCTestCase {

    func testDataNoNegative(data: MathPongGameWithOperandsData, lowerBound: Int = 0) {
        for add1 in lowerBound..<100 {
            for add2 in lowerBound..<100 {
                let wrongAnswers = data.wrongAnswers(operand1: add1, operand2: add2)
                XCTAssertNil(wrongAnswers.first { $0.prefix(1) == "-" })
            }
        }
    }

    func testDataOnlyWrong(data: MathPongGameWithOperandsData, lowerBound: Int = 0) {
        for add1 in lowerBound..<100 {
            for add2 in lowerBound..<100 {
                let correct = data.correctAnswer(operand1: add1, operand2: add2)
                let wrongAnswers = data.wrongAnswers(operand1: add1, operand2: add2)
                XCTAssertNil(wrongAnswers.first { $0 == correct })
            }
        }
    }

    func testAdditionDataNoNegative() {
        testDataNoNegative(data: AdditionData())
    }

    func testAdditionDataOnlyWrong() {
        testDataOnlyWrong(data: AdditionData())
    }

    func testMinusDataNoNegative() {
        testDataNoNegative(data: MinusData())
    }

    func testMinusDataOnlyWrong() {
        testDataOnlyWrong(data: MinusData())
    }

    func testMultiplicationDataNoNegative() {
        testDataNoNegative(data: MultiplicationData(), lowerBound: 2)
    }

    func testMultiplicationDataOnlyWrong() {
        testDataOnlyWrong(data: MultiplicationData(), lowerBound: 2)
    }

    func testDivisionDataNoNegative() {
        testDataNoNegative(data: DivisionData(), lowerBound: 2)
    }

    func testDivisionDataOnlyWrong() {
        testDataOnlyWrong(data: DivisionData(), lowerBound: 2)
    }

}
