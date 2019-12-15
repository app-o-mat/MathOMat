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
