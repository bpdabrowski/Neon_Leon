//
//  GameOverScene.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/29/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {

    public static let mainMenuPressedNotification = Notification.Name("MainMenuButtonPressed")

    let nodePictureAnimator = NodePictureAnimator()

    var newHighScoreSign: SKSpriteNode?

    var highScore: Int = UserDefaults.standard.integer(forKey: "HIGHSCORE")

    var restartButtonAction: (() -> Void)?

    var highScoreNumber: SKLabelNode!

    override func didMove(to view: SKView) {
        self.setupNodes()
    }

    private func setupNodes() {
        self.setupGameOverLabel()
        self.setupHighScoreLabel()
        self.setupButtons()
        self.setupHighScoreSign()
    }

    override func update(_ currentTime: TimeInterval) {
        self.highScoreNumber.text = "\(self.highScore)"
    }

    private func setupGameOverLabel() {
        let gameOverLabel = self.nodePictureAnimator.setupButton(pictureBase: "GameOver_00000",
                                                                 pictureWidth: 1100,
                                                                 pictureHeight: 600,
                                                                 buttonPositionX: -50,
                                                                 buttonPositionY: 620,
                                                                 zPosition: 8)

        let gameOverAnimation = self.nodePictureAnimator.buttonAnimation(animationBase: "GameOver_000",
                                                                         start: 1,
                                                                         end: 19,
                                                                         foreverStart: 20,
                                                                         foreverEnd: 35,
                                                                         startTimePerFrame: 0.035,
                                                                         foreverTimePerFrame: 0.035)

        self.addChild(gameOverLabel)
        gameOverLabel.run(gameOverAnimation)
    }

    private func setupHighScoreLabel() {
        let highScoreLabel = SKSpriteNode(imageNamed: "BestLabel_00000")
        highScoreLabel.position = CGPoint(x: -205, y: 0)
        self.addChild(highScoreLabel)

        let highScoreLabelAnimation = self.nodePictureAnimator.buttonAnimation(animationBase: "BestLabel_000",
                                                                               start: 1,
                                                                               end: 30,
                                                                               foreverStart: 31,
                                                                               foreverEnd: 60,
                                                                               startTimePerFrame: 0.06,
                                                                               foreverTimePerFrame: 0.06)

        highScoreLabel.run(highScoreLabelAnimation)

        self.highScoreNumber = SKLabelNode(fontNamed: "NeonTubes2-Regular")
        self.highScoreNumber.fontSize = 200
        self.highScoreNumber.position = CGPoint(x: 295, y: -45)
        self.addChild(highScoreNumber)
    }

    func setupButtons() {
        let mainMenuButton = Button(defaultButtonImage: "MainMenuButton", activeButtonImage: "MainMenuButton_Selected", buttonAction: {
            NotificationCenter.default.post(name: Self.mainMenuPressedNotification, object: nil)
        })
        mainMenuButton.position = CGPoint(x: 0, y: -500)
        addChild(mainMenuButton)

        let restartButton = Button(defaultButtonImage: "RestartButton", activeButtonImage: "RestartButton_Selected", buttonAction: { [weak self] in
            self?.restartButtonAction?()
        })
        restartButton.position = CGPoint(x: 0, y: -820)
        addChild(restartButton)
    }

    func setupHighScoreSign() {
        let newHighScoreSign = SKSpriteNode(imageNamed: "NewHighScoreSign")

        newHighScoreSign.xScale = 0
        newHighScoreSign.yScale = 0
        newHighScoreSign.position = CGPoint(x: 0, y: 0)
        newHighScoreSign.zPosition = 8
        self.newHighScoreSign = newHighScoreSign
        self.addChild(newHighScoreSign)

    }

    func playNewHighScoreAnimation() {
        let scaleIn = SKAction.scale(to: 4.5, duration: 0.5)
        let scaleOut = SKAction.scale(to: 0, duration: 2)
        self.run(SKAction.playSoundFileNamed("New Record.mp3", waitForCompletion: false))
        self.newHighScoreSign?.run(scaleIn)

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
            self.newHighScoreSign?.run(scaleOut)
            timer.invalidate()
        }
    }
}
