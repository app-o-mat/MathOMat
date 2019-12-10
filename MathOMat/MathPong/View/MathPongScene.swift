//
//  MathPongScene.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import SpriteKit
import GameplayKit

class MathPongScene: SKScene {
    var problemNode: SKNode?

    let players = [
        MathPongPlayer(problemRotation: 0, position: .bottom),
        MathPongPlayer(problemRotation: .pi, position: .top)]

    let data: MathPongGameData

    var currentProblem: MathPongProblem {
        didSet {
            updateProblem()
        }
    }
    var currentPlayer = 0

    enum Constants {
        static let problemName = "problem"
        static let playerLineName = ["player1line", "player2line"]
        static let buttonLineName = ["button1line", "button2line"]
        static let categoryObject: UInt32 = 0b0001
        static let categoryGuide: UInt32 = 0b0010
    }

    enum GameState {
        case waitingToStart
        case running
        case gameOver
    }

    var gameState = GameState.waitingToStart

    init(size: CGSize, data: MathPongGameData) {
        self.data = data
        self.currentProblem = self.data.getNextProblem()
        super.init(size: size)
    }

    let winSoundAction = SKAction.playSoundFileNamed("win", waitForCompletion: false)
    let loseSoundAction = SKAction.playSoundFileNamed("lose", waitForCompletion: false)

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMove(to view: SKView) {
        createGameBoard()
        physicsWorld.contactDelegate = self
    }

    func createGameBoard() {
        self.view?.backgroundColor = AppColor.boardBackground
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        createPlayerLine(yPosition: lineOffset(), playerIndex: 0)
        createPlayerLine(yPosition: self.size.height - lineOffset(), playerIndex: 1)

        createButtonLine(yPosition: lineOffset() * 3.5, playerIndex: 0)
        createButtonLine(yPosition: self.size.height - (lineOffset() * 3.5), playerIndex: 1)

        createGameBoundary(xPosition: 0)
        createGameBoundary(xPosition: self.size.width)

        let startButton = MathPongButtonNode(
            color: AppColor.startButtonBackground,
            size: CGSize(width: 200, height: 75))
        addChild(startButton)
        startButton.text = "Start"
        startButton.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        startButton.onTap = { [weak self] button in
            button.removeFromParent()
            self?.createRunningGameBoard()
        }
    }

    func createRunningGameBoard() {
        createButtons()
        createProblem()
    }

    func createPlayerLine(yPosition: CGFloat, playerIndex: Int) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: yPosition))
        path.addLine(to: CGPoint(x: self.size.width, y: yPosition))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 5
        boundary.strokeColor = AppColor.boundaryColor
        boundary.name = Constants.playerLineName[playerIndex]
        setupAsBoundary(line: boundary)

        boundary.physicsBody?.categoryBitMask = Constants.categoryGuide
        boundary.physicsBody?.collisionBitMask = Constants.categoryGuide

        addChild(boundary)
    }

    func createButtonLine(yPosition: CGFloat, playerIndex: Int) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: yPosition))
        path.addLine(to: CGPoint(x: self.size.width, y: yPosition))
        let guide = SKShapeNode(path: path)
        guide.lineWidth = 1
        guide.strokeColor = AppColor.guideColor
        guide.name = Constants.buttonLineName[playerIndex]
        guide.physicsBody = SKPhysicsBody(edgeChainFrom: guide.path!)

        guide.physicsBody?.categoryBitMask = Constants.categoryGuide
        guide.physicsBody?.collisionBitMask = Constants.categoryGuide

        addChild(guide)
    }

    func createProblem() {
        let label = SKLabelNode(text: self.currentProblem.question)
        label.fontSize = self.size.height / 20

        let problemSize = label.frame.size
        let problemNode = SKSpriteNode(color: AppColor.debugColor, size: problemSize)
        self.problemNode = problemNode
        addChild(problemNode)

        problemNode.name = Constants.problemName
        problemNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        problemNode.addChild(label)

        updateProblem()
    }

    func problemPhysicsBody(size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.linearDamping = 0.0
        physicsBody.contactTestBitMask = Constants.categoryGuide | Constants.categoryObject
        physicsBody.allowsRotation = false

        physicsBody.categoryBitMask = Constants.categoryObject
        physicsBody.collisionBitMask = Constants.categoryObject
        physicsBody.velocity = initialVelocity()

        return physicsBody
    }

    func removeButtons() {
        self.players.forEach { $0.removeButtons() }
    }

    func createButtons() {
        removeButtons()
        let buttons =
            self.players[currentPlayer].addButtons(scene: self, problem: currentProblem, lineOffset: lineOffset())

        buttons[0].onTap = { [weak self] button in
            self?.currentPlayerHits()
        }

        buttons[1].onTap = { [weak self] button in
            self?.currentPlayerMisses()
        }
        buttons[2].onTap = { [weak self] button in
            self?.currentPlayerMisses()
        }
    }

    func updateProblem() {
        guard
            let problemNode = self.problemNode as? SKSpriteNode,
            let label = problemNode.children[0] as? SKLabelNode
        else {
            return
        }

        label.text = currentProblem.question
        let problemSize = label.frame.size
        let rotation = self.players[self.currentPlayer].problemRotation
        label.zRotation = rotation
        if rotation == 0.0 {
            label.position = CGPoint(x: 0, y: -problemSize.height / 2.0)
        } else {
            label.position = CGPoint(x: 0, y: problemSize.height / 2.0)
        }

        problemNode.size = problemSize
        let newPhysicsBody = problemPhysicsBody(size: problemSize)
        if let physicsBody = problemNode.physicsBody {
            newPhysicsBody.velocity = physicsBody.velocity
        }
        problemNode.physicsBody = newPhysicsBody
        removeButtons()
    }

    func createGameBoundary(xPosition: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: self.size.height))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 2
        boundary.strokeColor = AppColor.boundaryColor
        setupAsBoundary(line: boundary)

        boundary.physicsBody?.categoryBitMask = Constants.categoryObject
        boundary.physicsBody?.collisionBitMask = Constants.categoryObject

        addChild(boundary)
    }

    func setupAsBoundary(line: SKShapeNode) {
        line.physicsBody = SKPhysicsBody(edgeChainFrom: line.path!)
        line.physicsBody?.restitution = 1.0
        line.physicsBody?.isDynamic = false
        line.physicsBody?.friction = 0
        line.physicsBody?.usesPreciseCollisionDetection = true
    }

    func currentPlayerHits() {
        guard let velocity = self.problemNode?.physicsBody?.velocity else { return }
        self.run(self.winSoundAction)

        self.currentPlayer = 1 - self.currentPlayer
        self.problemNode?.physicsBody?.velocity = CGVector(dx: velocity.dx * 1.1, dy: -velocity.dy * 1.1)

        self.currentProblem = self.data.getNextProblem()
    }

    func currentPlayerMisses() {
        self.run(self.loseSoundAction)

        self.problemNode?.physicsBody = nil
        self.problemNode?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

        self.currentProblem = self.data.getNextProblem()
    }

    func initialVelocity() -> CGVector {
        let dxy: CGFloat = self.size.height * 0.1
        return CGVector(dx: dxy * 0.5, dy: dxy * CGFloat(self.currentPlayer * 2 - 1))
    }
}

extension MathPongScene: SKPhysicsContactDelegate {

    func node(named name: String, contact: SKPhysicsContact) -> SKNode? {
        if contact.bodyA.node?.name ?? "" == name { return contact.bodyA.node }
        if contact.bodyB.node?.name ?? "" == name { return contact.bodyB.node }
        return nil
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard node(named: Constants.problemName, contact: contact) != nil else { return }
        if node(named: Constants.playerLineName[0], contact: contact) != nil {
            currentPlayerMisses()
        } else if node(named: Constants.playerLineName[1], contact: contact) != nil {
            currentPlayerMisses()
        } else if node(named: Constants.buttonLineName[currentPlayer], contact: contact) != nil {
            createButtons()
        }
    }

    func lineOffset() -> CGFloat {
        guard let view = self.view else { return 0.0 }

        let size = view.frame.size
        return size.height / 10 + 30
    }
}
