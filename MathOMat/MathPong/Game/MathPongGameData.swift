//
//  MathPongGameData.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit

struct MathPongProblem {
    let question: String
    let answer: String

    let wrongAnswers: Set<String>
}

protocol MathPongGameData {
    func getNextProblem() -> MathPongProblem
}

class MultiplicationData: MathPongGameData {

    func getNextProblem() -> MathPongProblem {
        let mult1 = GKRandomSource.sharedRandom().nextInt(upperBound: 10) + 2
        let mult2 = GKRandomSource.sharedRandom().nextInt(upperBound: 10) + 2

        let answer = mult1 * mult2
        var wrongAnswers = [
            "\(answer + 1)", "\(answer - 1)",
            "\(answer + 2)", "\(answer - 2)",
            "\(answer + 3)", "\(answer - 3)",
            "\(answer + mult1)", "\(answer + mult2)",
            "\(answer - mult1)", "\(answer - mult2)",
        ]
        if mult1 + mult2 != answer {
            wrongAnswers.append("\(mult1 + mult2)")
        }
        return MathPongProblem(question: "\(mult1) x \(mult2)", answer: "\(mult1 * mult2)",
            wrongAnswers: Set(wrongAnswers))
    }
}
