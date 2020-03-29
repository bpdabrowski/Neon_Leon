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

    override func viewDidLoad() {
        self.setupMainMenuScene()
        super.viewDidLoad()
    }

    func setupMainMenuScene() {
        // Set the scale mode to scale to fit the window
        self.mainMenuScene?.scaleMode = .aspectFill
        self.setupMainMenuButtonActions()

        self.spriteKitView.presentScene(self.mainMenuScene)

        self.gameViewController = self.preLoadedGameView() as? GameViewController
    }

    func setupMainMenuButtonActions() {
        guard let mainMenuScene = self.mainMenuScene as? MainMenuScene else {
            return
        }

        mainMenuScene.showGameView = { [weak self] in
            self?.showGameView()
        }
    }

    func preLoadedGameView() -> UIViewController {
        guard let gameViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameViewController") as? GameViewController else {
            print("Unable to preload Game View Controller")
            return UIViewController()
        }

        gameViewController.loadViewIfNeeded()

        return gameViewController
    }

    func showGameView() {
        if let gameViewController = self.gameViewController {
            self.present(gameViewController, animated: true, completion: nil)
        }
//        self.performSegue(withIdentifier: "showGameView", sender: self)
    }
}
