//
//  GameOverViewController.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/29/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import UIKit
import SpriteKit

class GameOverViewController: NeonLeonViewController {

    private var gameOverScene = SKScene(fileNamed: "GameOverScene")

    override func viewDidLoad() {
        self.setupGameOverScene()
        super.viewDidLoad()
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

    func showChallengeWonView() {
//            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] timer in
//                guard let self = self else { return }
//
//                if self.isQuarantineChallenge == true && self.score >= 50 {
//                    guard let gameViewController = self.view?.window?.rootViewController as? GameViewController else {
//                        return
//                    }
//                    gameViewController.highScore = self.score
//                    gameViewController.performSegue(withIdentifier: "SocialShareSegue", sender: gameViewController)
//                }
//                timer.invalidate()
//            }
//        })
    }
}
