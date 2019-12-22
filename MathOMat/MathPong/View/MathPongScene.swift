//
//  MathPongScene.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameOMatKit

class MathPongScene: GameScene {

    var opButtons = [ColorButtonNode]()
    var currentOp: MathOperator = MathOperator.add {
        didSet {
            didSetCurrentOp()
        }
    }

    init(size: CGSize) {
        let opIndex = UserDefaults.standard.integer(forKey: MathSettingKey.currentOpIndex)
        self.currentOp = MathOperator.at(index: opIndex)

        super.init(size: size, gameLogics:
            [PongOnePlayer(generator: MathOperator.add.generator()),
             PongTwoPlayer(generator: MathOperator.add.generator())])

        didSetCurrentOp()
    }

    override func didSetGameLogic() {
        super.didSetGameLogic()
        self.gameLogic.generator = self.currentOp.generator()
    }

    private func didSetCurrentOp() {
        UserDefaults.standard.set(currentOp.index(), forKey: MathSettingKey.currentOpIndex)
        resetOperatorButtons()
        self.gameLogic.generator = self.currentOp.generator()
    }

    override func addWaitingToStartButtons() {
        super.addWaitingToStartButtons()
        addOperatorButtons()
    }

    override func removeControlButtons() {
        super.removeControlButtons()
        removeOperatorButtons()
    }

    func addOperatorButtons() {
        var startPos = CGPoint(x: self.size.width / 2 - 96 - 10, y: self.size.height / 2 + 32 + 64 + 15)
        for op in MathOperator.allCases {
            self.opButtons.append(
                addOperatorButton(opName: op.rawValue, position: startPos, on: currentOp == op))
            startPos.y -= 64 + 10
        }
    }

    func resetOperatorButtons() {
        removeOperatorButtons()
        addOperatorButtons()
    }

    func removeOperatorButtons() {
        self.opButtons.forEach { $0.removeFromParent() }
        self.opButtons = []
    }

    func addOperatorButton(opName: String, position: CGPoint, on: Bool) -> ColorButtonNode {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Style.smallButtonSize)
        addChild(button)
        button.texture = SKTexture(imageNamed: "\(opName)-button-\(on ? "on" : "off")")
        button.position = position
        button.name = opName
        button.onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.currentOp = MathOperator.named(name: button.name) ?? MathOperator.add
        }
        return button
    }
}
