//
//  MathPongGameLogic.swift
//  MathOMat
//
//  Created by Louis Franco on 12/20/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class MathPongGameLogic: NSObject, GameLogic {
    let gamePhysics = GamePhysics()
    var allNodes = [SKNode]()

    weak var delegate: GameLogicDelegate?

    var currentOp: MathOperator = .add {
        didSet {
            self.currentProblem = currentOp.getNextProblem()
        }
    }

    var problemNode: SKNode?
    var currentProblem: Problem {
        didSet {
            didSetCurrentProblem()
        }
    }

    var currentPlayer = 0

    let winSoundAction = SKAction.playSoundFileNamed("win", waitForCompletion: false)
    let loseSoundAction = SKAction.playSoundFileNamed("lose", waitForCompletion: false)

    var scene: SKScene? {
        return self.delegate?.scene()
    }

    override init() {
        self.currentProblem = self.currentOp.getNextProblem()
        super.init()
    }

    func reset() {
    }

    func removeAllNodes() {
        allNodes.forEach { node in
            guard node.parent != nil else { return }
            node.removeFromParent()
        }
    }

    func addBoardNodes() {
        guard let scene = self.scene else { return }
        createGameBoundary(xPosition: Constants.sideInset)
        createGameBoundary(xPosition: scene.size.width - Constants.sideInset)
    }

    func run() {
        createProblem()
    }

    func add(node: SKNode, to parent: SKNode) {
        parent.addChild(node)
        allNodes.append(node)
    }

    func createGameBoundary(xPosition: CGFloat) {
        guard let scene = self.scene else { return }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: scene.size.height))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 2
        boundary.strokeColor = AppColor.boundaryColor

        gamePhysics.setupAsBoundary(node: boundary, path: path)
        gamePhysics.setupAsObject(node: boundary)

        add(node: boundary, to: scene)
    }

    func createProblem() {
        guard let scene = self.scene else { return }
        let label = SKLabelNode(text: self.currentProblem.question)
        label.fontSize = scene.size.height / 20
        label.fontName = Constants.fontName

        let problemSize = label.frame.size
        let problemNode = SKSpriteNode(color: AppColor.debugColor, size: problemSize)
        self.problemNode = problemNode
        add(node: problemNode, to: scene)

        problemNode.name = Constants.problemName
        problemNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        add(node: label, to: problemNode)

        didSetCurrentProblem()
    }

    func gameOver() {
        self.problemNode?.removeFromParent()
        self.problemNode = nil

        removeButtons()

        delegate?.didGameOver()
    }

    func setUpProblem(problemNode: SKSpriteNode, label: SKLabelNode) {

    }

    func didSetCurrentProblem() {
        guard
            let problemNode = self.problemNode as? SKSpriteNode,
            let label = problemNode.children[0] as? SKLabelNode,
            let scene = delegate?.scene()
        else { return }

        label.text = currentProblem.question
        let problemSize = label.frame.size

        setUpProblem(problemNode: problemNode, label: label)

        problemNode.size = problemSize
        let newPhysicsBody = problemPhysicsBody(scene: scene, size: problemSize)
        if let physicsBody = problemNode.physicsBody {
            newPhysicsBody.velocity = physicsBody.velocity
        }
        problemNode.physicsBody = newPhysicsBody
        removeButtons()
    }

    func problemPhysicsBody(scene: SKScene, size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.linearDamping = 0.0
        physicsBody.contactTestBitMask = GamePhysics.categoryGuide | GamePhysics.categoryObject
        physicsBody.allowsRotation = false

        gamePhysics.setupAsObject(physicsBody: physicsBody)
        physicsBody.velocity = initialVelocity(scene: scene)

        return physicsBody
    }

    func initialVelocity(scene: SKScene) -> CGVector {
        return CGVector(dx: 0, dy: 0)
    }

    func removeButtons() {

    }

    func createButtons() {

    }

    func addScoreNode(playerIndex: Int, yPosition: CGFloat) {
    }

    func createPlayerNodes(yPosition: CGFloat, playerIndex: Int) {
        guard let scene = self.scene else { return }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: Constants.sideInset, y: yPosition))
        path.addLine(to: CGPoint(x: scene.size.width - Constants.sideInset, y: yPosition))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 5
        boundary.strokeColor = AppColor.boundaryColor
        boundary.name = Constants.playerLineName[playerIndex]

        gamePhysics.setupAsBoundary(node: boundary, path: path)
        gamePhysics.setupAsGuide(node: boundary)

        add(node: boundary, to: scene)

        addScoreNode(playerIndex: playerIndex, yPosition: yPosition)
    }

    func createShowButtonsLine(yPosition: CGFloat, playerIndex: Int) {
        guard let scene = self.scene else { return }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: Constants.sideInset, y: yPosition))
        path.addLine(to: CGPoint(x: scene.size.width - Constants.sideInset, y: yPosition))

        let guide = SKShapeNode(path: path)
        guide.lineWidth = 1
        guide.strokeColor = AppColor.guideColor
        guide.name = Constants.buttonLineName[playerIndex]

        gamePhysics.setupAsBoundary(node: guide, path: path)
        gamePhysics.setupAsGuide(node: guide)

        add(node: guide, to: scene)
    }

    func lineOffset() -> CGFloat {
        guard let scene = self.scene, let view = scene.view else { return 0.0 }

        let size = view.frame.size
        let maxInset = max(view.safeAreaInsets.top, view.safeAreaInsets.bottom)

        return size.height / 10 + maxInset
    }

    func node(named name: String, contact: SKPhysicsContact) -> SKNode? {
        if contact.bodyA.node?.name ?? "" == name { return contact.bodyA.node }
        if contact.bodyB.node?.name ?? "" == name { return contact.bodyB.node }
        return nil
    }
}

extension MathPongTwoPlayer {

    private func playerDidMiss(_ contact: SKPhysicsContact, playerIndex: Int) -> Bool {
        return node(named: Constants.playerLineName[playerIndex], contact: contact) != nil
            && currentPlayer == playerIndex
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard node(named: Constants.problemName, contact: contact) != nil else { return }
        if playerDidMiss(contact, playerIndex: currentPlayer) {
            currentPlayerMisses()
        } else if node(named: Constants.buttonLineName[currentPlayer], contact: contact) != nil {
            createButtons()
        }
    }
}
