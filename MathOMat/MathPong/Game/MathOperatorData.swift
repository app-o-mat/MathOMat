//
//  MathOperatorData.swift
//  MathOMat
//
//  Created by Louis Franco on 12/15/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit

class AdditionData: MathPongGameData, MathPongGameWithOperandsData {
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

    func getNextProblem() -> MathPongProblem {
        let add1 = GKRandomSource.sharedRandom().nextInt(upperBound: 11)
        let add2 = GKRandomSource.sharedRandom().nextInt(upperBound: 11)

        return MathPongProblem(question: "\(add1) + \(add2)",
            answer: correctAnswer(operand1: add1, operand2: add2),
            wrongAnswers: wrongAnswers(operand1: add1, operand2: add2))
    }
}

class MinusData: MathPongGameData, MathPongGameWithOperandsData {

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

    func getNextProblem() -> MathPongProblem {
        let add1 = GKRandomSource.sharedRandom().nextInt(upperBound: 11)
        let add2 = GKRandomSource.sharedRandom().nextInt(upperBound: 11)

        let sum = add1 + add2

        return MathPongProblem(question: "\(sum) - \(add2)",
            answer: correctAnswer(operand1: add1, operand2: add2),
            wrongAnswers: wrongAnswers(operand1: add1, operand2: add2))
    }
}

class MultiplicationData: MathPongGameData, MathPongGameWithOperandsData {

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

    func getNextProblem() -> MathPongProblem {
        let mult1 = GKRandomSource.sharedRandom().nextInt(upperBound: 11) + 2
        let mult2 = GKRandomSource.sharedRandom().nextInt(upperBound: 11) + 2

        return MathPongProblem(question: "\(mult1) × \(mult2)",
            answer: correctAnswer(operand1: mult1, operand2: mult2),
            wrongAnswers: wrongAnswers(operand1: mult1, operand2: mult2))
    }
}

class DivisionData: MathPongGameData, MathPongGameWithOperandsData {

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

    func getNextProblem() -> MathPongProblem {
        let mult1 = GKRandomSource.sharedRandom().nextInt(upperBound: 11) + 2
        let mult2 = GKRandomSource.sharedRandom().nextInt(upperBound: 11) + 2

        let product = mult1 * mult2
        return MathPongProblem(question: "\(product) ÷ \(mult2)",
            answer: correctAnswer(operand1: mult1, operand2: mult2),
            wrongAnswers: wrongAnswers(operand1: mult1, operand2: mult2))
    }
}
