//
//  MathOperatorData.swift
//  MathOMat
//
//  Created by Louis Franco on 12/15/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit

class AdditionProblems: ProblemGenerator, ProblemFromOperands {
    let smallestOperand = 0
    let biggestOperand = 10

    func question(operand1: Int, operand2: Int) -> String {
        return "\(operand1) + \(operand2)"
    }

    func correctAnswer(operand1: Int, operand2: Int) -> String {
        return "\(operand1 + operand2)"
    }

    func wrongAnswers(operand1: Int, operand2: Int) -> Set<String> {
        let sum = operand1 + operand2
        var wrongAnswers = [
            "\(sum + 1)",
            "\(sum + 2)",
            "\(sum + 3)",
            "\(sum + operand1)", "\(sum + operand2)",
            "\(sum - operand1)", "\(sum - operand2)",
            "\(operand1 * operand2)",
        ]

        if sum >= 1 {
            wrongAnswers.append("\(sum - 1)")
            if sum >= 2 {
                wrongAnswers.append("\(sum - 2)")
                if sum >= 3 {
                    wrongAnswers.append("\(sum - 3)")
                }
            }
        }

        wrongAnswers.removeAll { "\(sum)" == $0 }
        return Set(wrongAnswers)
    }

}

class MinusProblems: ProblemGenerator, ProblemFromOperands {
    let smallestOperand = 0
    let biggestOperand = 10

    func question(operand1: Int, operand2: Int) -> String {
        return "\(operand1 + operand2) - \(operand2)"
    }

    func correctAnswer(operand1: Int, operand2: Int) -> String {
        return "\(operand1)"
    }

    func wrongAnswers(operand1: Int, operand2: Int) -> Set<String> {
        var wrongAnswers = [
            "\(operand1 + 1)", "\(operand2)",
            "\(operand1 + 2)",
        ]

        if operand1 >= 1 {
            wrongAnswers.append("\(operand1 - 1)")
            if operand1 >= 2 {
                wrongAnswers.append("\(operand1 - 2)")
            }
        }

        wrongAnswers.removeAll { "\(operand1)" == $0 }
        return Set(wrongAnswers)
    }
}

class MultiplicationProblems: ProblemGenerator, ProblemFromOperands {
    let smallestOperand = 2
    let biggestOperand = 12

    func question(operand1: Int, operand2: Int) -> String {
        return "\(operand1) × \(operand2)"
    }

    func correctAnswer(operand1: Int, operand2: Int) -> String {
        return "\(operand1 * operand2)"
    }

    func wrongAnswers(operand1: Int, operand2: Int) -> Set<String> {
        let product = operand1 * operand2
        var wrongAnswers = [
            "\(product + 1)", "\(product - 1)",
            "\(product + 2)", "\(product - 2)",
            "\(product + 3)", "\(product - 3)",
            "\(product + operand1)", "\(product + operand2)",
            "\(product - operand1)", "\(product - operand2)",
            "\(operand1 + operand2)",
        ]

        wrongAnswers.removeAll { "\(product)" == $0 }

        return Set(wrongAnswers)
    }
}

class DivisionProblems: ProblemGenerator, ProblemFromOperands {
    let smallestOperand = 2
    let biggestOperand = 12

    func question(operand1: Int, operand2: Int) -> String {
        return "\(operand1 * operand2) ÷ \(operand2)"
    }

    func correctAnswer(operand1: Int, operand2: Int) -> String {
        return "\(operand1)"
    }

    func wrongAnswers(operand1: Int, operand2: Int) -> Set<String> {
        let product = operand1 * operand2
        var wrongAnswers = [
            "\(operand1 + 1)", "\(operand1 - 1)",
            "\(operand1 + 2)", "\(operand1 - 2)",
            "\(product - operand2)",
        ]

        wrongAnswers.removeAll { "\(operand1)" == $0 }
        return Set(wrongAnswers)
    }
}
