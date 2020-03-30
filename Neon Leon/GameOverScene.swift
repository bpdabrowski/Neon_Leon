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

    var restartButtonAction: (() -> Void)?

    override func didMove(to view: SKView) {
        self.setupNodes()
    }

    private func setupNodes() {
        self.setupGameOverLabel()
        self.setupHighScoreLabel()
        self.setupButtons()
    }

    private func setupGameOverLabel() {
        let gameOverLabel = self.nodePictureAnimator.setupButton(pictureBase: "GameOver_00000",
                                                                 pictureWidth: 1100,
                                                                 pictureHeight: 600,
                                                                 buttonPositionX: -50,
                                                                 buttonPositionY: 918,
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
        highScoreLabel.position = CGPoint(x: -205, y: 425)
        self.addChild(highScoreLabel)

        let highScoreLabelAnimation = self.nodePictureAnimator.buttonAnimation(animationBase: "BestLabel_000",
                                                                               start: 1,
                                                                               end: 30,
                                                                               foreverStart: 31,
                                                                               foreverEnd: 60,
                                                                               startTimePerFrame: 0.06,
                                                                               foreverTimePerFrame: 0.06)

        highScoreLabel.run(highScoreLabelAnimation)

        let highScoreNumber = SKLabelNode(fontNamed: "NeonTubes2-Regular")
        highScoreNumber.fontSize = 200
        highScoreNumber.position = CGPoint(x: 295, y: 380)
        highScoreNumber.text = "\(UserDefaults().integer(forKey: "HIGHSCORE"))"
        self.addChild(highScoreNumber)
    }

    func setupButtons() {
        let mainMenuButton = Button(defaultButtonImage: "MainMenuButton", activeButtonImage: "MainMenuButton_Selected", buttonAction: { [weak self] in
            NotificationCenter.default.post(name: Self.mainMenuPressedNotification, object: nil)
        })
        mainMenuButton.position = CGPoint(x: 0, y: 0)
        addChild(mainMenuButton)

        let restartButton = Button(defaultButtonImage: "RestartButton", activeButtonImage: "RestartButton_Selected", buttonAction: { [weak self] in
            self?.restartButtonAction?()
        })
        restartButton.position = CGPoint(x: 0, y: -320)
        addChild(restartButton)
    }
}
