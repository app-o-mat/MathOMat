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
    var scoreNodes = [SKLabelNode(), SKLabelNode()]

    var startButton: MathPongButtonNode?
    var pauseButton: MathPongButtonNode?

    var currentPlayer = 0
    let players = [
        MathPongPlayer(problemRotation: 0, position: .bottom),
        MathPongPlayer(problemRotation: .pi, position: .top)]

    let data: MathPongGameData

    var currentProblem: MathPongProblem {
        didSet {
            updateProblem()
        }
    }

    enum Constants {
        static let problemName = "problem"
        static let playerLineName = ["player1line", "player2line"]
        static let buttonLineName = ["button1line", "button2line"]
        static let categoryObject: UInt32 = 0b0001
        static let categoryGuide: UInt32 = 0b0010
        static let fontName = "Courier"
        static let sideInset: CGFloat = 5
    }

    enum GameState {
        case waitingToStart
        case running
        case paused
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
        physicsWorld.contactDelegate = self
        self.isUserInteractionEnabled = true
        self.backgroundColor = AppColor.boardBackground
    }

    func startGame() {
        createGameBoard()
    }

    func createGameBoard() {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        createPlayerLine(yPosition: lineOffset(), playerIndex: 0)
        createPlayerLine(yPosition: self.size.height - lineOffset(), playerIndex: 1)

        let guidePos = self.size.height / 3.0
        createShowButtonsLine(yPosition: guidePos, playerIndex: 0)
        createShowButtonsLine(yPosition: self.size.height - guidePos, playerIndex: 1)

        createGameBoundary(xPosition: Constants.sideInset)
        createGameBoundary(xPosition: self.size.width - Constants.sideInset)

        addStartButton()
    }

    func removeControlButtons() {
        self.pauseButton?.removeFromParent()
        self.pauseButton = nil
        self.startButton?.removeFromParent()
        self.startButton = nil
    }

    func addStartButton() {
        removeControlButtons()

        let button = MathPongButtonNode(
            color: AppColor.startButtonBackground,
            size: CGSize(width: 128, height: 128))
        self.startButton = button
        addChild(button)
        button.texture = SKTexture(imageNamed: "play-button")
        button.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        button.onTap = { [weak self] button in
            guard let sself = self else { return }

            if sself.gameState == .paused {
                sself.unPauseGame()
            } else if sself.gameState == .waitingToStart {
                sself.createRunningGameBoard()
            }
            sself.addPauseButton()
        }
    }

    func addPauseButton() {
        removeControlButtons()

        let button = MathPongButtonNode(
            color: AppColor.startButtonBackground,
            size: CGSize(width: 128, height: 128))
        self.pauseButton = button
        addChild(button)
        button.texture = SKTexture(imageNamed: "pause-button")
        button.alpha = 0.4
        button.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        button.onTap = { [weak self] button in
            button.removeFromParent()
            self?.pauseGame()
            self?.addStartButton()
        }
    }

    func createRunningGameBoard() {
        self.players[0].score = 0
        self.players[1].score = 0
        self.scoreNodes[0].text = "0"
        self.scoreNodes[1].text = "0"
        createProblem()
        self.gameState = .running
    }

    func createPlayerLine(yPosition: CGFloat, playerIndex: Int) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: Constants.sideInset, y: yPosition))
        path.addLine(to: CGPoint(x: self.size.width - Constants.sideInset, y: yPosition))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 5
        boundary.strokeColor = AppColor.boundaryColor
        boundary.name = Constants.playerLineName[playerIndex]
        setupAsBoundary(line: boundary)

        boundary.physicsBody?.categoryBitMask = Constants.categoryGuide
        boundary.physicsBody?.collisionBitMask = Constants.categoryGuide

        addChild(boundary)

        let score = self.scoreNodes[playerIndex]
        score.text = "\(self.players[playerIndex].score)"
        score.fontName = Constants.fontName
        score.fontSize *= 2
        score.position = CGPoint(x: score.fontSize + 5, y: yPosition - 50 * CGFloat(playerIndex * 2 - 1))
        score.zRotation = .pi / 2.0
        addChild(score)
    }

    func createShowButtonsLine(yPosition: CGFloat, playerIndex: Int) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: Constants.sideInset, y: yPosition))
        path.addLine(to: CGPoint(x: self.size.width - Constants.sideInset, y: yPosition))
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
        label.fontName = Constants.fontName

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
            guard self?.gameState == .running else { return }
            self?.currentPlayerHits()
        }

        buttons[1].onTap = { [weak self] button in
            guard self?.gameState == .running else { return }
            self?.currentPlayerMisses()
        }

        buttons[2].onTap = { [weak self] button in
            guard self?.gameState == .running else { return }
            self?.currentPlayerMisses()
        }
    }

    func updateProblem() {
        guard
            let problemNode = self.problemNode as? SKSpriteNode,
            let label = problemNode.children[0] as? SKLabelNode
        else { return }

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

        let otherPlayer = 1 - currentPlayer
        self.players[otherPlayer].score += 1
        scoreNodes[otherPlayer].text = "\(self.players[otherPlayer].score)"

        guard self.players[otherPlayer].score < 7 else { return gameOver() }

        self.problemNode?.physicsBody = nil
        self.problemNode?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

        self.currentProblem = self.data.getNextProblem()
    }

    func initialVelocity() -> CGVector {
        let dxy: CGFloat = self.size.height * 0.1
        return CGVector(dx: dxy * 0.5, dy: dxy * CGFloat(self.currentPlayer * 2 - 1))
    }

    func gameOver() {
        self.problemNode?.removeFromParent()
        self.problemNode = nil
        addStartButton()
        self.gameState = .waitingToStart
    }

    func pauseGame() {
        self.gameState = .paused
        self.isPaused = true
    }

    func unPauseGame() {
        self.gameState = .running
        self.isPaused = false
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
        let maxInset = max(view.safeAreaInsets.top, view.safeAreaInsets.bottom)

        return size.height / 10 + maxInset
    }
}
