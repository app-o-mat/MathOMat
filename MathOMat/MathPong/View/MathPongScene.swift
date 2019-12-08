//
//  MathPongScene.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import SpriteKit
import GameplayKit

class MathPongScene: SKScene {
    let problem = SKLabelNode(text: "")

    let data: MathPongGameData
    var currentProblem: MathPongProblem

    init(size: CGSize, data: MathPongGameData) {
        self.data = data
        self.currentProblem = self.data.getNextProblem()
        super.init(size: size)

        self.problem.text = self.currentProblem.question
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMove(to view: SKView) {
        addChild(problem)
        problem.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
    }
}
