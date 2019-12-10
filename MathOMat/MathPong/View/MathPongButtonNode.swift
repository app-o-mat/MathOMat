//
//  AnswerButtonNode.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import SpriteKit

class MathPongButtonNode: SKSpriteNode {
    private let labelNode = SKLabelNode()
    private let flipped: Bool
    var onTap: ((MathPongButtonNode) -> Void)?

    public var text: String? {
        get { return labelNode.text }
        set {
            labelNode.text = newValue
            updateText()
        }

    }
    init(color: UIColor, size: CGSize, flipped: Bool = false) {
        self.flipped = flipped
        super.init(texture: nil, color: color, size: size)
        self.isUserInteractionEnabled = true
        addChild(labelNode)
        labelNode.fontSize = size.height * 0.8
        labelNode.fontName = "Courier"
        if flipped {
            labelNode.zRotation = .pi
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func updateText() {
        if flipped {
            labelNode.position = CGPoint(x: 0, y: labelNode.frame.size.height / 2.0)
        } else {
            labelNode.position = CGPoint(x: 0, y: -(labelNode.frame.size.height) / 2.0)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.onTap?(self)
    }
}
