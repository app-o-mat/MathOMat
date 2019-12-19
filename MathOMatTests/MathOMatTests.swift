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

    func testDataNoNegative(data: ProblemFromOperands, lowerBound: Int = 0) {
        for add1 in lowerBound..<100 {
            for add2 in lowerBound..<100 {
                let wrongAnswers = data.wrongAnswers(operand1: add1, operand2: add2)
                XCTAssertNil(wrongAnswers.first { $0.prefix(1) == "-" })
            }
        }
    }

    func testDataOnlyWrong(data: ProblemFromOperands, lowerBound: Int = 0) {
        for add1 in lowerBound..<100 {
            for add2 in lowerBound..<100 {
                let correct = data.correctAnswer(operand1: add1, operand2: add2)
                let wrongAnswers = data.wrongAnswers(operand1: add1, operand2: add2)
                XCTAssertNil(wrongAnswers.first { $0 == correct })
            }
        }
    }

    func testAdditionDataNoNegative() {
        testDataNoNegative(data: AdditionProblems())
    }

    func testAdditionDataOnlyWrong() {
        testDataOnlyWrong(data: AdditionProblems())
    }

    func testMinusDataNoNegative() {
        testDataNoNegative(data: MinusProblems())
    }

    func testMinusDataOnlyWrong() {
        testDataOnlyWrong(data: MinusProblems())
    }

    func testMultiplicationDataNoNegative() {
        testDataNoNegative(data: MultiplicationProblems(), lowerBound: 2)
    }

    func testMultiplicationDataOnlyWrong() {
        testDataOnlyWrong(data: MultiplicationProblems(), lowerBound: 2)
    }

    func testDivisionDataNoNegative() {
        testDataNoNegative(data: DivisionProblems(), lowerBound: 2)
    }

    func testDivisionDataOnlyWrong() {
        testDataOnlyWrong(data: DivisionProblems(), lowerBound: 2)
    }

}
