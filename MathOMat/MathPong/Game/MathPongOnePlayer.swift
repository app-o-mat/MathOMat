//
//  MathPongOnePlayer.swift
//  MathOMat
//
//  Created by Louis Franco on 12/20/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class MathPongOnePlayer: MathPongGameLogic {

    var scoreNode = SKLabelNode()
    let player = MathPongPlayer(problemRotation: 0, position: .bottom)

    override func reset() {
        super.reset()
        self.player.score = 0
        self.scoreNode.text = "0"
    }

    override func addBoardNodes() {
        super.addBoardNodes()
        guard let scene = self.scene else { return }

        createPlayerNodes(yPosition: lineOffset(), playerIndex: 0)

        let guidePos = scene.size.height / 3.0
        createShowButtonsLine(yPosition: guidePos, playerIndex: 0)
    }
}
