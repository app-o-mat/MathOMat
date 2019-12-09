//
//  MathPongPlayer.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

enum PlayerPosition {
    case bottom
    case top

    func buttonYPosition(viewSize: CGSize, lineOffset: CGFloat) -> CGFloat {
        switch self {
        case .bottom:
            return lineOffset / 2.0
        case .top:
            return viewSize.height - lineOffset / 2.0
        }
    }
}

class MathPongPlayer {
    let problemRotation: CGFloat
    let position: PlayerPosition
    var velocity: CGFloat = 1.0

    let hues: [CGFloat] = (0..<37).map { (i: Int) in CGFloat(1.0 / 35.0) * CGFloat(i) }
    var currentHue = 0
    func nextHue() -> CGFloat {
        defer {
            currentHue = (currentHue + 5) % hues.count
        }
        return hues[currentHue]
    }

    var buttons = [AnswerButtonNode]()
    let buttonWidth: CGFloat = 100.0

    init(problemRotation: CGFloat, position: PlayerPosition) {
        self.problemRotation = problemRotation
        self.position = position
    }

    func addButton(scene: SKScene, xPos: CGFloat, text: String, lineOffset: CGFloat) -> AnswerButtonNode {
        let button = AnswerButtonNode(
            color: UIColor.init(
                hue: nextHue(),
                saturation: 0.75, brightness: 0.5, alpha: 1.0),
            size: CGSize(width: buttonWidth, height: 70),
            flipped: position == .top)
        button.position =
            CGPoint(x: xPos,
                    y: position.buttonYPosition(viewSize: scene.size, lineOffset: lineOffset))
        button.text = text
        scene.addChild(button)
        return button
    }

    func addButtons(scene: SKScene, problem: MathPongProblem, lineOffset: CGFloat) {
        let possiblePositions: [CGFloat] = [scene.size.width / 2.0,
                                            scene.size.width / 2.0 - buttonWidth - 20,
                                            scene.size.width / 2.0 + buttonWidth + 20 ]
        let positions: [CGFloat] = GKRandomSource.sharedRandom()
            .arrayByShufflingObjects(in: possiblePositions).map { ($0 as? CGFloat) ?? 0.0 }
        let wrongAnswers = GKRandomSource.sharedRandom()
            .arrayByShufflingObjects(in: [String](problem.wrongAnswers))
            .map { ($0 as? String) ?? "" }

        self.buttons = [
            addButton(scene: scene, xPos: positions[0], text: problem.answer, lineOffset: lineOffset),
            addButton(scene: scene, xPos: positions[1], text: wrongAnswers[0], lineOffset: lineOffset),
            addButton(scene: scene, xPos: positions[2], text: wrongAnswers[1], lineOffset: lineOffset),
        ]
    }

    func removeButtons() {
        self.buttons.forEach { $0.removeFromParent() }
    }
}
