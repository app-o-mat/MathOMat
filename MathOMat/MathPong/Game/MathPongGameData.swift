//
//  MathPongGameData.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation

struct MathPongProblem {
    let question: String
    let answer: String

    let wrongAnswers: [String]
}

protocol MathPongGameData {
    func getNextProblem() -> MathPongProblem
}

class MultiplicationData: MathPongGameData {

    let problems = [
        ("5 x 7", "35", ["33", "38", "30", "45", "57"]),
        ("3 x 8", "24", ["38", "26", "20", "21", "27"]),
    ].map { MathPongProblem(question: $0.0, answer: $0.1, wrongAnswers: $0.2) }
    var currentProblemIndex = 0

    func getNextProblem() -> MathPongProblem {
        defer { currentProblemIndex = (currentProblemIndex + 1) % problems.count }
        return problems[currentProblemIndex]
    }
}
