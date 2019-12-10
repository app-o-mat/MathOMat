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
    var problem: SKNode?

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

        boundary.physicsBody?.categoryBitMask = Constants.categoryObject
        boundary.physicsBody?.collisionBitMask = Constants.categoryObject

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
        let problem = SKShapeNode(rectOf: problemSize)
        self.problem = problem
        addChild(problem)

        problem.fillColor = AppColor.debugColor
        problem.strokeColor = AppColor.debugColor
        problem.name = Constants.problemName
        problem.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

        let physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: problemSize.width, height: problemSize.height))

        let dxy: CGFloat = self.size.height * 0.1
        physicsBody.velocity = CGVector(dx: dxy * 0.5, dy: -dxy)
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.linearDamping = 0.0
        physicsBody.contactTestBitMask = Constants.categoryGuide | Constants.categoryObject
        physicsBody.allowsRotation = false

        physicsBody.categoryBitMask = Constants.categoryObject
        physicsBody.collisionBitMask = Constants.categoryObject

        problem.physicsBody = physicsBody

        problem.addChild(label)

        updateProblem()
    }

    func removeButtons() {
        self.players.forEach { $0.removeButtons() }
    }

    func createButtons() {
        removeButtons()
        let buttons =
            self.players[currentPlayer].addButtons(scene: self, problem: currentProblem, lineOffset: lineOffset())

        buttons[0].onTap = { [weak self] button in
            guard let sself = self, let velocity = sself.problem?.physicsBody?.velocity else { return }
            sself.run(sself.winSoundAction)
            sself.currentPlayer = 1 - sself.currentPlayer
            sself.problem?.physicsBody?.velocity = CGVector(dx: velocity.dx * 1.1, dy: -velocity.dy * 1.1)
            sself.currentProblem = sself.data.getNextProblem()
        }

        buttons[1].onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.run(sself.loseSoundAction)
        }
        buttons[2].onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.run(sself.loseSoundAction)
        }
    }

    func updateProblem() {
        guard let label = self.problem?.children[0] as? SKLabelNode else { return }

        label.text = currentProblem.question
        let problemSize = label.frame.size
        let rotation = self.players[self.currentPlayer].problemRotation
        label.zRotation = rotation
        if rotation == 0.0 {
            label.position = CGPoint(x: 0, y: -problemSize.height / 2.0)
        } else {
            label.position = CGPoint(x: 0, y: problemSize.height / 2.0)
        }
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
            self.currentPlayer = 1
            self.run(self.loseSoundAction)
        } else if node(named: Constants.playerLineName[1], contact: contact) != nil {
            self.currentPlayer = 0
            self.run(self.loseSoundAction)
        } else {
            if node(named: Constants.buttonLineName[currentPlayer], contact: contact) != nil {
                createButtons()
            }
            return
        }
        self.currentProblem = self.data.getNextProblem()
    }

    func lineOffset() -> CGFloat {
        guard let view = self.view else { return 0.0 }

        let size = view.frame.size
        return size.height / 10 + 30
    }
}
