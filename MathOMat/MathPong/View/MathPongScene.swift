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

    var currentProblem: MathPongProblem
    var currentPlayer = 0

    enum Constants {
        static let problemName = "problem"
        static let playerLineName = ["player1line", "player2line"]
        static let lineOffset: CGFloat = 150
    }

    init(size: CGSize, data: MathPongGameData) {
        self.data = data
        self.currentProblem = self.data.getNextProblem()
        super.init(size: size)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func didMove(to view: SKView) {
        createGameBoard()
        createProblem()
        physicsWorld.contactDelegate = self
    }

    func createGameBoard() {
        self.view?.backgroundColor = UIColor(hue: 0.0, saturation: 0.0, brightness: 0.2, alpha: 1.0)
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        createPlayerLine(yPosition: Constants.lineOffset, playerIndex: 0)
        createPlayerLine(yPosition: self.size.height - Constants.lineOffset, playerIndex: 1)

        createGameBoundary(xPosition: 0)
        createGameBoundary(xPosition: self.size.width)

        createButtons()
    }

    func createPlayerLine(yPosition: CGFloat, playerIndex: Int) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: yPosition))
        path.addLine(to: CGPoint(x: self.size.width, y: yPosition))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 5
        boundary.strokeColor = UIColor.white
        boundary.name = Constants.playerLineName[playerIndex]
        setupAsBoundary(line: boundary)
        addChild(boundary)
    }

    func createProblem() {
        let label = SKLabelNode(text: self.currentProblem.question)
        label.fontSize = self.size.height / 20

        let problemSize = label.frame.size
        let problem = SKShapeNode(rectOf: problemSize)
        self.problem = problem
        addChild(problem)

        problem.fillColor = UIColor.clear
        problem.strokeColor = UIColor.clear
        problem.name = Constants.problemName
        problem.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

        let physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: problemSize.width, height: problemSize.height))
        physicsBody.velocity = CGVector(dx: 150, dy: -240.0)
        physicsBody.usesPreciseCollisionDetection = true
        physicsBody.linearDamping = 0.0
        physicsBody.contactTestBitMask = physicsBody.collisionBitMask
        physicsBody.allowsRotation = false
        problem.physicsBody = physicsBody

        problem.addChild(label)

        updateProblem()
    }

    func createButtons() {
        self.players.forEach { $0.removeButtons() }
        self.players[currentPlayer].addButtons(scene: self, problem: currentProblem, lineOffset: Constants.lineOffset)
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
        createButtons()
    }

    func createGameBoundary(xPosition: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: xPosition, y: 0))
        path.addLine(to: CGPoint(x: xPosition, y: self.size.height))
        let boundary = SKShapeNode(path: path)
        boundary.lineWidth = 2
        boundary.strokeColor = UIColor.white
        setupAsBoundary(line: boundary)
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
        } else if node(named: Constants.playerLineName[1], contact: contact) != nil {
            self.currentPlayer = 0
        } else {
            return
        }
        self.currentProblem = self.data.getNextProblem()
        updateProblem()
    }

}
