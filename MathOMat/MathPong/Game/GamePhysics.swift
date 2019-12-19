//
//  GamePhysics.swift
//  MathOMat
//
//  Created by Louis Franco on 12/18/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit

struct GamePhysics {

    static let categoryObject: UInt32 = 0b0001
    static let categoryGuide: UInt32 = 0b0010

    func setupAsGuide(node: SKNode) {
        node.physicsBody?.categoryBitMask = GamePhysics.categoryGuide
        node.physicsBody?.collisionBitMask = GamePhysics.categoryGuide
    }

    func setupAsGuide(physicsBody: SKPhysicsBody?) {
        physicsBody?.categoryBitMask = GamePhysics.categoryGuide
        physicsBody?.collisionBitMask = GamePhysics.categoryGuide
    }

    func setupAsObject(node: SKNode) {
        node.physicsBody?.categoryBitMask = GamePhysics.categoryObject
        node.physicsBody?.collisionBitMask = GamePhysics.categoryObject
    }

    func setupAsObject(physicsBody: SKPhysicsBody?) {
        physicsBody?.categoryBitMask = GamePhysics.categoryObject
        physicsBody?.collisionBitMask = GamePhysics.categoryObject
    }

    func setupAsBoundary(node: SKNode, path: CGPath) {
        node.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        node.physicsBody?.restitution = 1.0
        node.physicsBody?.isDynamic = false
        node.physicsBody?.friction = 0
        node.physicsBody?.usesPreciseCollisionDetection = true
    }

}
