//
//  MathPongSceneViewController.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class MathPongSceneViewController: UIViewController {

    var scene: SKScene?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startGame()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func startGame() {
        guard self.scene == nil else { return }
        self.scene = MathPongScene(size: view.frame.size,
                                  data: MultiplicationData())
        if let skView = view as? SKView {
            skView.presentScene(scene)
        }
    }
}
