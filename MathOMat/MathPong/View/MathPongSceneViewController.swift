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

    override func viewDidLoad() {
        let scene = MathPongScene(size: view.frame.size, data: MultiplicationData())
        if let skView = view as? SKView {
            skView.presentScene(scene)
        }
    }
}
