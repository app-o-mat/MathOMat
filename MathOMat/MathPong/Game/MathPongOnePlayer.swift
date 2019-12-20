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

class MathPongOnePlayer: MathPongGameLogic, GameLogicPlayers {

    var scoreNode = SKLabelNode()
    let players = [MathPongPlayer(problemRotation: 0, position: .bottom)]
    var player: MathPongPlayer {
        return players[0]
    }

    override func reset() {
        super.reset()
        self.player.score = 0
        self.scoreNode.text = "0"
    }

    override func getPlayers() -> GameLogicPlayers? {
        return self
    }

    override func addBoardNodes() {
        super.addBoardNodes()
        guard let scene = self.scene else { return }

        createPlayerNodes(yPosition: lineOffset(), playerIndex: 0)

        let guidePos = scene.size.height / 2.0
        createShowButtonsLine(yPosition: guidePos, playerIndex: 0)
    }

    override func addScoreNode(playerIndex: Int, yPosition: CGFloat) {
        super.addScoreNode(playerIndex: playerIndex, yPosition: yPosition)
        guard let scene = self.scene, let view = scene.view else { return }

        let score = self.scoreNode
        score.text = "\(self.player.score)"
        score.fontName = Constants.fontName
        score.fontSize *= 2
        score.position = CGPoint(x: scene.size.width / 2,
                                 y: scene.size.height - view.safeAreaInsets.top - score.frame.size.height - 10)
        add(node: score, to: scene)
    }

    override func initialPosition(scene: SKScene) -> CGPoint {
        guard let view = scene.view else { return super.initialPosition(scene: scene) }

        return CGPoint(x: scene.size.width / 2, y: scene.size.height - view.safeAreaInsets.top)
    }

    override func initialVelocity(scene: SKScene) -> CGVector {
        let dxy: CGFloat = scene.size.height * 0.1
        return CGVector(dx: dxy * 0.5, dy: -dxy)
    }

    func currentPlayerHits() {
        guard let scene = self.scene else { return }

        guard let velocity = self.problemNode?.physicsBody?.velocity else { return }
        scene.run(self.winSoundAction)

        self.problemNode?.physicsBody = nil
        self.problemNode?.position = initialPosition(scene: scene)

        self.currentProblem = self.currentOp.getNextProblem()

        self.problemNode?.physicsBody?.velocity = CGVector(dx: velocity.dx * 1.1, dy: velocity.dy * 1.1)

        self.player.score += 1
        scoreNode.text = "\(self.player.score)"
    }

    func currentPlayerMisses() {
        guard let scene = self.scene else { return }

        scene.run(self.loseSoundAction)
        gameOver()
    }
}
