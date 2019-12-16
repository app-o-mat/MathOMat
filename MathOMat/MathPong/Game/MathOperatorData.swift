//
//  MathOperatorData.swift
//  MathOMat
//
//  Created by Louis Franco on 12/15/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit

class AdditionData: MathPongGameData {

    func getNextProblem() -> MathPongProblem {
        let add1 = GKRandomSource.sharedRandom().nextInt(upperBound: 11)
        let add2 = GKRandomSource.sharedRandom().nextInt(upperBound: 11)

        let sum = add1 + add2
        var wrongAnswers = [
            "\(sum + 1)",
            "\(sum + 2)",
            "\(sum + 3)",
            "\(sum + add1)", "\(sum + add2)",
            "\(sum - add1)", "\(sum - add2)",
            "\(add1 * add2)",
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

        return MathPongProblem(question: "\(add1) + \(add2)", answer: "\(sum)",
            wrongAnswers: Set(wrongAnswers))
    }
}

class MinusData: MathPongGameData {

    func getNextProblem() -> MathPongProblem {
        let add1 = GKRandomSource.sharedRandom().nextInt(upperBound: 11)
        let add2 = GKRandomSource.sharedRandom().nextInt(upperBound: 11)

        let sum = add1 + add2
        var wrongAnswers = [
            "\(add1 + 1)", "\(add2)",
            "\(add1 + 2)",
        ]

        if add1 >= 1 {
            wrongAnswers.append("\(add1 - 1)")
            if add1 >= 2 {
                wrongAnswers.append("\(add1 - 2)")
            }
        }

        wrongAnswers.removeAll { "\(add1)" == $0 }

        return MathPongProblem(question: "\(sum) - \(add2)", answer: "\(add1)",
            wrongAnswers: Set(wrongAnswers))
    }
}

class MultiplicationData: MathPongGameData {

    func getNextProblem() -> MathPongProblem {
        let mult1 = GKRandomSource.sharedRandom().nextInt(upperBound: 11) + 2
        let mult2 = GKRandomSource.sharedRandom().nextInt(upperBound: 11) + 2

        let product = mult1 * mult2
        var wrongAnswers = [
            "\(product + 1)", "\(product - 1)",
            "\(product + 2)", "\(product - 2)",
            "\(product + 3)", "\(product - 3)",
            "\(product + mult1)", "\(product + mult2)",
            "\(product - mult1)", "\(product - mult2)",
            "\(mult1 + mult2)",
        ]

        wrongAnswers.removeAll { "\(product)" == $0 }

        return MathPongProblem(question: "\(mult1) × \(mult2)", answer: "\(product)",
            wrongAnswers: Set(wrongAnswers))
    }
}

class DivisionData: MathPongGameData {

    func getNextProblem() -> MathPongProblem {
        let mult1 = GKRandomSource.sharedRandom().nextInt(upperBound: 11) + 2
        let mult2 = GKRandomSource.sharedRandom().nextInt(upperBound: 11) + 2

        let product = mult1 * mult2
        var wrongAnswers = [
            "\(mult1 + 1)", "\(mult1 - 1)",
            "\(mult1 + 2)", "\(mult1 - 2)",
            "\(product - mult2)",
        ]

        wrongAnswers.removeAll { "\(mult1)" == $0 }

        return MathPongProblem(question: "\(product) ÷ \(mult2)", answer: "\(mult1)",
            wrongAnswers: Set(wrongAnswers))
    }
}
