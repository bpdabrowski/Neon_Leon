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

    var lastGameScore = 0

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

        gameScene.isQuarantineChallenge = self.isQuarantineChallenge
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

        gameOverViewController.isQuarantineChallenge = self.isQuarantineChallenge

        // Set the scale mode to scale to fit the window
        gameScene.scaleMode = .aspectFill
        gameScene.gameOverAction = { [weak self] score in
            guard let self = self else { return }

            self.lastGameScore = score
            if self.isQuarantineChallenge == true {
                if score >= 50 {
                    self.performSegue(withIdentifier: "ChallengeWonSegue", sender: self)
                } else {
                    self.performSegue(withIdentifier: "ChallengeLostSegue", sender: self)
                }
            } else {
                self.performSegue(withIdentifier: "GameOverSegue", sender: self)
            }

            self.gameScene = nil
        }

        self.spriteKitView.presentScene(gameScene)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let quarantineChallengeViewController = segue.destination as? QuarantineChallengeViewController {
            quarantineChallengeViewController.lastGameScore = self.lastGameScore
        } else if let gameOverViewController = segue.destination as? GameOverViewController {
            gameOverViewController.lastGameScore = self.lastGameScore
        }
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
}
