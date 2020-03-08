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
            [PongOnePlayerLogic(generator: MathOperator.add.generator()),
             PongTwoPlayerLogic(generator: MathOperator.add.generator())])

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
        for (i, op) in MathOperator.allCases.enumerated() {
            let pos = super.buttonPosition(xGridOffset: -1.5 + CGFloat(i), yGridOffset: -1.0)
            self.opButtons.append(
                addOperatorButton(opName: op.rawValue, position: pos, on: currentOp == op))
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
