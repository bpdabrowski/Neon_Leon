//
//  GameOverViewController.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/29/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import UIKit
import SpriteKit
import StoreKit

class GameOverViewController: NeonLeonViewController {

    private var gameOverScene = SKScene(fileNamed: "GameOverScene")

    var lastGameScore: Int = 0

    override func viewDidLoad() {
        self.setupGameOverScene()

        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.handleNewHighScoreIfNeeded()
        super.viewDidAppear(animated)
    }

    func setupGameOverScene() {
        guard let gameOverScene = self.gameOverScene as? GameOverScene else {
            return
        }

        gameOverScene.restartButtonAction = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        gameOverScene.scaleMode = .aspectFill

        self.spriteKitView.presentScene(self.gameOverScene)
    }

    func handleNewHighScoreIfNeeded() {
        guard let gameOverScene = self.gameOverScene as? GameOverScene else {
            return
        }

        if self.lastGameScore > UserDefaults.standard.integer(forKey: "HIGHSCORE") {
            gameOverScene.highScore = self.lastGameScore
            gameOverScene.playNewHighScoreAnimation()
            UserDefaults().set(self.lastGameScore, forKey: "HIGHSCORE")

            if #available(iOS 10.3, *) {
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
                    SKStoreReviewController.requestReview()
                    timer.invalidate()
                }
            }
        } else {
            gameOverScene.highScore = UserDefaults.standard.integer(forKey: "HIGHSCORE")
        }
    }
}
