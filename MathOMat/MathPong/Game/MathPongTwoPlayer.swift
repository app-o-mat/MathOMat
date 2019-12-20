//
//  MathPongTwoPlayer.swift
//  MathOMat
//
//  Created by Louis Franco on 12/19/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

class MathPongTwoPlayer: NSObject, GameLogic {
    let gamePhysics = GamePhysics()
    weak var delegate: GameLogicDelegate?

    var scoreNodes = [SKLabelNode(), SKLabelNode()]

    var problemNode: SKNode?
    var currentProblem: Problem {
        didSet {
            didSetCurrentProblem()
        }
    }

    let winSoundAction = SKAction.playSoundFileNamed("win", waitForCompletion: false)
    let loseSoundAction = SKAction.playSoundFileNamed("lose", waitForCompletion: false)

    var currentPlayer = 0
    let players = [
        MathPongPlayer(problemRotation: 0, position: .bottom),
        MathPongPlayer(problemRotation: .pi, position: .top)]

    var currentOp: MathOperator = .add {
        didSet {
            self.currentProblem = currentOp.getNextProblem()
        }
    }

    var scene: SKScene? {
        return self.delegate?.scene()
    }

    override init() {
        self.currentProblem = self.currentOp.getNextProblem()
        super.init()
    }

    func reset() {
        self.players[0].score = 0
        self.players[1].score = 0
        self.scoreNodes[0].text = "0"
        self.scoreNodes[1].text = "0"
    }

    func addBoardNodes() {
        guard let scene = self.scene else { return }

        createPlayerLine(yPosition: lineOffset(), playerIndex: 0)
        createPlayerLine(yPosition: scene.size.height - lineOffset(), playerIndex: 1)

        let guidePos = scene.size.height / 3.0
        createShowButtonsLine(yPosition: guidePos, playerIndex: 0)
        createShowButtonsLine(yPosition: scene.size.height - guidePos, playerIndex: 1)

        createGameBoundary(xPosition: Constants.sideInset)
        createGameBoundary(xPosition: scene.size.width - Constants.sideInset)
    }

    func run() {
        createProblem()
    }

    func createProblem() {
        guard let scene = self.scene else { return }
        let label = SKLabelNode(text: self.currentProblem.question)
        label.fontSize = scene.size.height / 20
        label.fontName = Constants.fontName

        let problemSize = label.frame.size
        let problemNode = SKSpriteNode(color: AppColor.debugColor, size: problemSize)
        self.problemNode = problemNode
        scene.addChild(problemNode)

        problemNode.name = Constants.problemName
        problemNode.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
        problemNode.addChild(label)

        didSetCurrentProblem()
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

    func didSetCurrentProblem() {
        guard
            let problemNode = self.problemNode as? SKSpriteNode,
            let label = problemNode.children[0] as? SKLabelNode,
            let scene = delegate?.scene()
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
        let newPhysicsBody = problemPhysicsBody(scene: scene, size: problemSize)
        if let physicsBody = problemNode.physicsBody {
            newPhysicsBody.velocity = physicsBody.velocity
        }
        problemNode.physicsBody = newPhysicsBody
        removeButtons()
    }

    func initialVelocity(scene: SKScene) -> CGVector {
        let dxy: CGFloat = scene.size.height * 0.1
        return CGVector(dx: dxy * 0.5, dy: dxy * CGFloat(self.currentPlayer * 2 - 1))
    }

    private func createPlayerLine(yPosition: CGFloat, playerIndex: Int) {
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

        scene.addChild(boundary)

        addScoreNode(playerIndex: playerIndex, yPosition: yPosition)
    }

    private func createGameBoundary(xPosition: CGFloat) {
        guard let scene = self.scene else { return }

        let path = CGMutablePath()
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: scene.size.height))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 2
        boundary.strokeColor = AppColor.boundaryColor

        gamePhysics.setupAsBoundary(node: boundary, path: path)
        gamePhysics.setupAsObject(node: boundary)

        scene.addChild(boundary)
    }

    private func createShowButtonsLine(yPosition: CGFloat, playerIndex: Int) {
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

        scene.addChild(guide)
    }

    private func addScoreNode(playerIndex: Int, yPosition: CGFloat) {
        guard let scene = self.scene else { return }

        let score = self.scoreNodes[playerIndex]
        score.text = "\(self.players[playerIndex].score)"
        score.fontName = Constants.fontName
        score.fontSize *= 2
        score.position = CGPoint(x: score.fontSize + 5, y: yPosition - 50 * CGFloat(playerIndex * 2 - 1))
        score.zRotation = .pi / 2.0
        scene.addChild(score)
    }

    private func removeButtons() {
        self.players.forEach { $0.removeButtons() }
    }

    private func createButtons() {
        guard let scene = self.scene else { return }

        removeButtons()
        let buttons =
            self.players[currentPlayer].addButtons(scene: scene, problem: currentProblem, lineOffset: lineOffset())

        buttons[0].onTap = { [weak self] button in
            guard self?.delegate?.gameState == .running else { return }
            self?.currentPlayerHits()
        }

        buttons[1].onTap = { [weak self] button in
            guard self?.delegate?.gameState == .running else { return }
            self?.currentPlayerMisses()
        }

        buttons[2].onTap = { [weak self] button in
            guard self?.delegate?.gameState == .running else { return }
            self?.currentPlayerMisses()
        }
    }

    func currentPlayerHits() {
        guard let scene = self.scene else { return }

        guard let velocity = self.problemNode?.physicsBody?.velocity else { return }
        scene.run(self.winSoundAction)

        self.currentPlayer = 1 - self.currentPlayer
        self.problemNode?.physicsBody?.velocity = CGVector(dx: velocity.dx * 1.1, dy: -velocity.dy * 1.1)

        self.currentProblem = self.currentOp.getNextProblem()
    }

    func currentPlayerMisses() {
        guard let scene = self.scene else { return }

        scene.run(self.loseSoundAction)

        let otherPlayer = 1 - currentPlayer
        self.players[otherPlayer].score += 1
        scoreNodes[otherPlayer].text = "\(self.players[otherPlayer].score)"

        guard self.players[otherPlayer].score < 7 else { return gameOver() }

        self.problemNode?.physicsBody = nil
        self.problemNode?.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)

        self.currentProblem = self.currentOp.getNextProblem()
    }

    func lineOffset() -> CGFloat {
        guard let scene = self.scene, let view = scene.view else { return 0.0 }

        let size = view.frame.size
        let maxInset = max(view.safeAreaInsets.top, view.safeAreaInsets.bottom)

        return size.height / 10 + maxInset
    }

    func gameOver() {
        self.problemNode?.removeFromParent()
        self.problemNode = nil

        removeButtons()

        delegate?.didGameOver()
    }
}

extension MathPongTwoPlayer {

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
}
