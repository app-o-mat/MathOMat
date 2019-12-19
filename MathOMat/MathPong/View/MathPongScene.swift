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
    let gamePhysics = GamePhysics()

    var problemNode: SKNode?
    var scoreNodes = [SKLabelNode(), SKLabelNode()]

    var startButton: ColorButtonNode?
    var pauseButton: ColorButtonNode?
    var themeButton: ColorButtonNode?
    var resetButton: ColorButtonNode?

    var opButtons = [ColorButtonNode]()
    var currentOp: MathOperator = MathOperator.add {
        didSet {
            UserDefaults.standard.set(currentOp.index(), forKey: Constants.settingKey.currentOpIndex)
            resetOperatorButtons()
        }
    }

    var backgroundIndex = 0 {
        didSet {
            UserDefaults.standard.set(backgroundIndex, forKey: Constants.settingKey.backgroundIndex)
            self.backgroundColor = AppColor.boardBackground[backgroundIndex]
        }
    }

    var currentPlayer = 0
    let players = [
        MathPongPlayer(problemRotation: 0, position: .bottom),
        MathPongPlayer(problemRotation: .pi, position: .top)]

    var currentProblem: Problem {
        didSet {
            didSetCurrentProblem()
        }
    }

    enum Constants {
        static let problemName = "problem"
        static let playerLineName = ["player1line", "player2line"]
        static let buttonLineName = ["button1line", "button2line"]

        static let fontName = "Courier"

        static let sideInset: CGFloat = 5
        static let settingKey = (
            backgroundIndex: "math-pong.settingKey.backgroundIndex",
            currentOpIndex: "math-pong.settingKey.currentOpIndex")
        static let smallButtonSize = CGSize(width: 64, height: 64)
    }

    enum GameState {
        case waitingToStart
        case running
        case paused
    }
    var gameState = GameState.waitingToStart

    let winSoundAction = SKAction.playSoundFileNamed("win", waitForCompletion: false)
    let loseSoundAction = SKAction.playSoundFileNamed("lose", waitForCompletion: false)

    override init(size: CGSize) {
        self.backgroundIndex = UserDefaults.standard.integer(forKey: Constants.settingKey.backgroundIndex)
        let opIndex = UserDefaults.standard.integer(forKey: Constants.settingKey.currentOpIndex)
        self.currentOp = MathOperator.at(index: opIndex)

        self.currentProblem = currentOp.getNextProblem()
        super.init(size: size)

        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        self.backgroundColor = AppColor.boardBackground[backgroundIndex]

        subscribeToAppEvents()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // App Events
    private func subscribeToAppEvents() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(appBecameActive),
                                       name: UIApplication.didBecomeActiveNotification, object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(appResignActive),
                                       name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func appBecameActive() {
        if self.gameState != .waitingToStart {
            pauseGame()
            removeControlButtons()
            addStartButton()
        }
    }

    @objc private func appResignActive() {
        if self.gameState != .waitingToStart {
            pauseGame()
        }
    }

    func startGame() {
        createGameBoard()
        addWaitingToStartButtons()
    }

    func addWaitingToStartButtons() {
        removeControlButtons()
        addStartButton()
        addThemeButton()
        addOperatorButtons()
    }

    func createGameBoard() {
        createPlayerLine(yPosition: lineOffset(), playerIndex: 0)
        createPlayerLine(yPosition: self.size.height - lineOffset(), playerIndex: 1)

        let guidePos = self.size.height / 3.0
        createShowButtonsLine(yPosition: guidePos, playerIndex: 0)
        createShowButtonsLine(yPosition: self.size.height - guidePos, playerIndex: 1)

        createGameBoundary(xPosition: Constants.sideInset)
        createGameBoundary(xPosition: self.size.width - Constants.sideInset)
    }

    func removeControlButtons() {
        self.pauseButton?.removeFromParent()
        self.pauseButton = nil
        self.startButton?.removeFromParent()
        self.startButton = nil
        self.themeButton?.removeFromParent()
        self.themeButton = nil
        self.resetButton?.removeFromParent()
        self.resetButton = nil
        removeOperatorButtons()
    }

    func addStartButton() {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: CGSize(width: 128, height: 128))
        self.startButton = button
        addChild(button)
        button.texture = SKTexture(imageNamed: "play-button")
        button.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        button.onTap = { [weak self] button in
            self?.onStartTapped()
        }
    }

    func addThemeButton() {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Constants.smallButtonSize)
        self.themeButton = button
        addChild(button)
        button.texture = SKTexture(imageNamed: "theme-button")
        button.position = CGPoint(x: self.size.width / 2 + 96 + 10, y: self.size.height / 2)
        button.onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.backgroundIndex =  (sself.backgroundIndex + 1) % AppColor.boardBackground.count
        }
    }

    func addResetButton() {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Constants.smallButtonSize)
        self.resetButton = button
        addChild(button)
        button.texture = SKTexture(imageNamed: "reset-button")
        button.position = CGPoint(x: self.size.width / 2 + 96 + 10, y: self.size.height / 2)
        button.onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.reset()
        }
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
            size: Constants.smallButtonSize)
        addChild(button)
        button.texture = SKTexture(imageNamed: "\(opName)-button-\(on ? "on" : "off")")
        button.position = position
        button.name = opName
        button.onTap = { [weak self] button in
            guard let sself = self else { return }
            sself.currentOp = MathOperator.named(name: button.name) ?? MathOperator.add
            sself.currentProblem = sself.currentOp.getNextProblem()
        }
        return button
    }

    func onStartTapped() {
        if self.gameState == .paused {
            unPauseGame()
        } else if self.gameState == .waitingToStart {
            createRunningGameBoard()
        }
        addPauseButton()
    }

    func addPauseButton() {
        removeControlButtons()

        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: CGSize(width: 128, height: 128))
        self.pauseButton = button
        addChild(button)
        button.texture = SKTexture(imageNamed: "pause-button")
        button.alpha = 0.4
        button.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        button.onTap = { [weak self] button in
            self?.onPauseTapped()
        }
    }

    func onPauseTapped() {
        pauseGame()
        removeControlButtons()
        addStartButton()
        addResetButton()
    }

    func createRunningGameBoard() {
        resetScore()
        createProblem()
        self.gameState = .running
    }

    func resetScore() {
        self.players[0].score = 0
        self.players[1].score = 0
        self.scoreNodes[0].text = "0"
        self.scoreNodes[1].text = "0"
    }

    func createPlayerLine(yPosition: CGFloat, playerIndex: Int) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: Constants.sideInset, y: yPosition))
        path.addLine(to: CGPoint(x: self.size.width - Constants.sideInset, y: yPosition))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 5
        boundary.strokeColor = AppColor.boundaryColor
        boundary.name = Constants.playerLineName[playerIndex]

        gamePhysics.setupAsBoundary(node: boundary, path: path)
        gamePhysics.setupAsGuide(node: boundary)

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

        gamePhysics.setupAsBoundary(node: guide, path: path)
        gamePhysics.setupAsGuide(node: guide)

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

        didSetCurrentProblem()
    }

    func problemPhysicsBody(size: CGSize) -> SKPhysicsBody {
        let physicsBody = SKPhysicsBody(rectangleOf: size)

        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.linearDamping = 0.0
        physicsBody.contactTestBitMask = GamePhysics.categoryGuide | GamePhysics.categoryObject
        physicsBody.allowsRotation = false

        gamePhysics.setupAsObject(physicsBody: physicsBody)
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

    func didSetCurrentProblem() {
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

        gamePhysics.setupAsBoundary(node: boundary, path: path)
        gamePhysics.setupAsObject(node: boundary)

        addChild(boundary)
    }

    func currentPlayerHits() {
        guard let velocity = self.problemNode?.physicsBody?.velocity else { return }
        self.run(self.winSoundAction)

        self.currentPlayer = 1 - self.currentPlayer
        self.problemNode?.physicsBody?.velocity = CGVector(dx: velocity.dx * 1.1, dy: -velocity.dy * 1.1)

        self.currentProblem = self.currentOp.getNextProblem()
    }

    func currentPlayerMisses() {
        self.run(self.loseSoundAction)

        let otherPlayer = 1 - currentPlayer
        self.players[otherPlayer].score += 1
        scoreNodes[otherPlayer].text = "\(self.players[otherPlayer].score)"

        guard self.players[otherPlayer].score < 7 else { return gameOver() }

        self.problemNode?.physicsBody = nil
        self.problemNode?.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

        self.currentProblem = self.currentOp.getNextProblem()
    }

    func initialVelocity() -> CGVector {
        let dxy: CGFloat = self.size.height * 0.1
        return CGVector(dx: dxy * 0.5, dy: dxy * CGFloat(self.currentPlayer * 2 - 1))
    }

    func gameOver() {
        self.problemNode?.removeFromParent()
        self.problemNode = nil
        addWaitingToStartButtons()
        self.gameState = .waitingToStart
    }

    func reset() {
        unPauseGame()
        gameOver()
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

    func lineOffset() -> CGFloat {
        guard let view = self.view else { return 0.0 }

        let size = view.frame.size
        let maxInset = max(view.safeAreaInsets.top, view.safeAreaInsets.bottom)

        return size.height / 10 + maxInset
    }
}
