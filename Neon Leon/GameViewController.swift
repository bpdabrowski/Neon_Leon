//
//  GameViewController.swift
//  Neon Leion
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2018 BD Creative. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase
import AVFoundation
import SwiftyStoreKit
import StoreKit

var backgroundMusicPlayer: AVAudioPlayer?

class GameViewController: NeonLeonViewController {

    var soundOff = false

    var highScore = 0

    var gameScene: SKScene?

    var isQuarantineChallenge = false

    var gameOverViewController: GameOverViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupGameScene()
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let gameScene = self.gameScene as? GameScene else {
            print("Unable to get a reference to GameScene")
            return
        }

        gameScene.isQuarantineChallenge = isQuarantineChallenge
        gameScene.startGame()

        super.viewDidAppear(true)
    }

    func setupGameScene() {
        self.gameScene = SKScene(fileNamed: "GameScene")
        
        guard let gameScene = self.gameScene as? GameScene else {
            return
        }

        if self.gameOverViewController == nil {
            self.gameOverViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GameOverViewController") as? GameOverViewController
        }

        guard let gameOverViewController = self.gameOverViewController else {
            return
        }

        // Set the scale mode to scale to fit the window
        gameScene.scaleMode = .aspectFill
        gameScene.gameOverAction = { [weak self] in
            self?.present(gameOverViewController, animated: true) { [weak self] in
                self?.gameScene = nil
            }
        }

        self.spriteKitView.presentScene(gameScene)
    }

    func setupSound() {
        let path = Bundle.main.path(forResource: "Spacebased_Full.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        if soundOff == true {
            //change button to a sound with an x in it.
        } else if soundOff == false {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                // couldn't load file
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let socialShareViewController = segue.destination as? SocialShareViewController {
            socialShareViewController.highScore = self.highScore
            socialShareViewController.dismissCompletion = {
                let alert = UIAlertController(title: "Share Challenge With Everyone!",
                                              message: "We have also saved a screenshot of the challenge to your photos. Please share to all your social networks to encourage people to donate to the CDC Foundation.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Open Photos", style: .default) { _ in
                    guard let photosUrl = URL(string:"photos-redirect://") else {
                        return
                    }
                    UIApplication.shared.open(photosUrl)
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
