//
//  MainMenuViewController.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/28/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenuViewController: NeonLeonViewController {

    private var mainMenuScene = SKScene(fileNamed: "MainMenuScene")

    private var gameViewController: GameViewController?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gameViewController = self.preLoadedGameView() as? GameViewController
        self.setupMainMenuButtonActions()
    }

    override func viewDidLoad() {
        self.setupMainMenuScene()
        super.viewDidLoad()
    }

    func setupMainMenuScene() {
        // Set the scale mode to scale to fit the window
        self.mainMenuScene?.scaleMode = .aspectFill

        self.spriteKitView.presentScene(self.mainMenuScene)
    }

    func setupMainMenuButtonActions() {
        guard let mainMenuScene = self.mainMenuScene as? MainMenuScene else {
            return
        }

        mainMenuScene.showGameView = { [weak self] in
            self?.showGameView()
        }

        mainMenuScene.showGameViewQuarantineChallenge = { [weak self] in
            self?.showGameView(isQuarantineChallenge: true)
        }
    }

    func preLoadedGameView() -> UIViewController {
        guard let gameViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else {
            print("Unable to preload Game View Controller")
            return UIViewController()
        }

        gameViewController.loadViewIfNeeded()
        gameViewController.setupGameScene()

        return gameViewController
    }

    func showGameView(isQuarantineChallenge: Bool = false) {
        if let gameViewController = self.gameViewController, let gameScene = gameViewController.gameScene as? GameScene {
            gameViewController.isQuarantineChallenge = isQuarantineChallenge

            self.present(gameViewController, animated: true, completion: nil)
        }
    }
}
