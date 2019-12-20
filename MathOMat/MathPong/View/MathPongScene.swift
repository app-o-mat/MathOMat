//
//  MathPongScene.swift
//  MathOMat
//
//  Created by Louis Franco on 12/8/19.
//  Copyright © 2019 App-o-Mat. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Constants {
    static let problemName = "problem"
    static let playerLineName = ["player1line", "player2line"]
    static let buttonLineName = ["button1line", "button2line"]

    static let fontName = "Courier"

    static let sideInset: CGFloat = 5
    static let settingKey = (
        backgroundIndex: "math-pong.settingKey.backgroundIndex",
        currentOpIndex: "math-pong.settingKey.currentOpIndex",
        numberOfPlayers: "math-pong.settingKey.numberOfPlayers")
    static let smallButtonSize = CGSize(width: 64, height: 64)
}

enum GameState {
    case waitingToStart
    case running
    case paused
}

protocol GameLogicDelegate: class {
    var gameState: GameState { get }

    func didGameOver()
    func scene() -> SKScene
}

protocol GameLogic: SKPhysicsContactDelegate {
    var delegate: GameLogicDelegate? { get set }
    var currentOp: MathOperator { get set }

    func reset()
    func addBoardNodes()
    func run()
    func gameOver()
}

extension GameLogic {
}

class MathPongScene: SKScene {

    var gameLogic: GameLogic = MathPongTwoPlayer()

    var startButton: ColorButtonNode?
    var pauseButton: ColorButtonNode?
    var themeButton: ColorButtonNode?
    var resetButton: ColorButtonNode?

    var playerButtons = [ColorButtonNode]()

    var opButtons = [ColorButtonNode]()
    var currentOp: MathOperator = MathOperator.add {
        didSet {
            didSetCurrentOp()
        }
    }

    var backgroundIndex = 0 {
        didSet {
            UserDefaults.standard.set(backgroundIndex, forKey: Constants.settingKey.backgroundIndex)
            self.backgroundColor = AppColor.boardBackground[backgroundIndex]
        }
    }

    var numberOfPlayers = 2 {
        didSet {
            UserDefaults.standard.set(numberOfPlayers, forKey: Constants.settingKey.numberOfPlayers)
        }
    }

    var gameState = GameState.waitingToStart

    override init(size: CGSize) {
        self.backgroundIndex = UserDefaults.standard.integer(forKey: Constants.settingKey.backgroundIndex)

        let opIndex = UserDefaults.standard.integer(forKey: Constants.settingKey.currentOpIndex)
        self.currentOp = MathOperator.at(index: opIndex)

        let storedNumberOfPlayers = UserDefaults.standard.integer(forKey: Constants.settingKey.numberOfPlayers)
        self.numberOfPlayers = (storedNumberOfPlayers > 0) ? storedNumberOfPlayers : 2

        super.init(size: size)

        self.gameLogic.delegate = self
        didSetCurrentOp()

        self.physicsWorld.contactDelegate = self.gameLogic
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        self.backgroundColor = AppColor.boardBackground[backgroundIndex]

        subscribeToAppEvents()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func didSetCurrentOp() {
        UserDefaults.standard.set(currentOp.index(), forKey: Constants.settingKey.currentOpIndex)
        resetOperatorButtons()
        self.gameLogic.currentOp = self.currentOp
    }

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
        addPlayerButtons()
    }

    func createGameBoard() {
        gameLogic.addBoardNodes()
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
        removePlayerButtons()
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
        button.position = CGPoint(x: self.size.width / 2 + 96 + 10, y: self.size.height / 2 + 32 + 64 + 15)
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
        }
        return button
    }

    func addPlayerButtons() {
        var startPos = CGPoint(x: self.size.width / 2 + 64 + 10 + 32,
                               y: self.size.height / 2  - 5 - 32)
        for (i, player) in ["1p", "2p"].enumerated() {
            self.playerButtons.append(
                addPlayerButton(name: player, position: startPos, on: numberOfPlayers == (i+1)))
            startPos.y -= 64 + 5
        }
    }

    func addPlayerButton(name: String, position: CGPoint, on: Bool) -> ColorButtonNode {
        let button = ColorButtonNode(
            color: AppColor.imageButtonBackground,
            size: Constants.smallButtonSize)
        addChild(button)
        button.texture = SKTexture(imageNamed: "\(name)-button-\(on ? "on" : "off")")
        button.position = position
        button.name = name
        button.onTap = { [weak self] button in
            guard let sself = self, let name = button.name else { return }
            sself.numberOfPlayers = Int(String(name.prefix(1))) ?? 1
            sself.resetPlayerButtons()
        }
        return button
    }

    func resetPlayerButtons() {
        removePlayerButtons()
        addPlayerButtons()
    }

    func removePlayerButtons() {
        self.playerButtons.forEach { $0.removeFromParent() }
        self.playerButtons = []
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
        gameLogic.reset()
        gameLogic.run()
        self.gameState = .running
    }

    func reset() {
        unPauseGame()
        gameLogic.gameOver()
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

extension MathPongScene: GameLogicDelegate {
    func didGameOver() {
        addWaitingToStartButtons()
        self.gameState = .waitingToStart
    }

    func scene() -> SKScene {
        return self
    }
}
