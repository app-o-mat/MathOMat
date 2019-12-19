//
//  ProblemGenerator.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit

struct Problem {
    let question: String
    let answer: String

    let wrongAnswers: Set<String>
}

protocol ProblemGenerator {
    func getNextProblem() -> Problem
}

protocol ProblemFromOperands {

    var smallestOperand: Int { get }
    var biggestOperand: Int { get }

    func getNextOperands() -> (Int, Int)
    func correctAnswer(operand1: Int, operand2: Int) -> String
    func wrongAnswers(operand1: Int, operand2: Int) -> Set<String>
    func question(operand1: Int, operand2: Int) -> String
}

extension ProblemFromOperands {
    func getNextOperands() -> (Int, Int) {
        let upperBound = biggestOperand - smallestOperand + 1
        return (GKRandomSource.sharedRandom().nextInt(upperBound: upperBound) + smallestOperand,
                GKRandomSource.sharedRandom().nextInt(upperBound: upperBound) + smallestOperand)
    }

    func getNextProblem() -> Problem {
        let (operand1, operand2) = getNextOperands()

        return Problem(question: question(operand1: operand1, operand2: operand2),
            answer: correctAnswer(operand1: operand1, operand2: operand2),
            wrongAnswers: wrongAnswers(operand1: operand1, operand2: operand2))
    }
}
