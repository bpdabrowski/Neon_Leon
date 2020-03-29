//
//  MainMenuScene.swift
//  Neon Leion
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2018 BD Creative. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    var playButton: Button!
    var reviewButton: Button!
    var quarantineChallengeButton: Button!
    var tutorialButton: Button!
    var settingsButton: Button!
    var soundButton: Button!
    var soundImage: SKSpriteNode!
    let userDefaults = UserDefaults.standard
    var tutorialButtonImage: SKSpriteNode!
    let notification = UINotificationFeedbackGenerator()

    var showGameView: (() -> Void)?

    var showGameViewQuarantineChallenge: (() -> Void)?
    
    var settingsButtonSelected = false

    static let appStoreLink = URL(string: "https://apps.apple.com/us/app/neon-leion/id1352620219?ls=1")

    override func didMove(to view: SKView) {
        setupNodes()
        
        if userDefaults.integer(forKey: "HIGHSCORE") <= 5 {
            tutorialButtonImage = childNode(withName: "Tutorial") as? SKSpriteNode
            let bounceUp = SKAction.move(by: CGVector(dx: 0, dy: 40), duration: 0.3)
            let dropDown = SKAction.move(by: CGVector(dx: 0, dy: -40), duration: 0.17)
            let bounceSequence = SKAction.sequence([bounceUp,dropDown,bounceUp,dropDown])
            let wait1 = SKAction.wait(forDuration: 1)
            let wait2 = SKAction.wait(forDuration: 2)
            let sequence = SKAction.sequence([wait1,bounceSequence,wait2,bounceSequence,wait2,bounceSequence])
            tutorialButtonImage.run(sequence)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.notification.notificationOccurred(.error)
            })
        }
    }
    
    func showGameScene(isQuarantineChallenge: Bool = false) {
        var newScene = GameScene(fileNamed: "GameScene")

        if userDefaults.integer(forKey: "HIGHSCORE") <= 3 {
            newScene = GameScene(fileNamed: "Controls")
        }

        newScene?.isQuarantineChallenge = isQuarantineChallenge
        newScene!.scaleMode = .aspectFill
        let reveal = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene!, transition: reveal)
    }
    
    func setupNodes() {
        playButton = Button(defaultButtonImage: "PlayButton", activeButtonImage: "PlayButton_Selected", buttonAction: {
            self.showGameView?()
        })
        playButton.position = CGPoint(x: 0, y: 75)
        playButton.alpha = 1
        playButton.zPosition = 10
        addChild(playButton)
        
        reviewButton = Button(defaultButtonImage: "ReviewButton", activeButtonImage: "ReviewButton_Selected", buttonAction: appStorePage)
        reviewButton.position = CGPoint(x: 0, y: -825)
        reviewButton.alpha = 1
        reviewButton.zPosition = 10
        addChild(reviewButton)

        self.quarantineChallengeButton = Button(defaultButtonImage: "QChalButton", activeButtonImage: "QChalButton_Selected", buttonAction: {
            self.showGameViewQuarantineChallenge?()
        })
        self.quarantineChallengeButton.position = CGPoint(x: 0, y: -225)
        self.quarantineChallengeButton.alpha = 1
        self.quarantineChallengeButton.zPosition = 10
        self.addChild(self.quarantineChallengeButton)

        tutorialButton = Button(defaultButtonImage: "TutorialButton", activeButtonImage: "TutorialButton_Selected", buttonAction: showTutorialScene)
        tutorialButton.position = CGPoint(x: 0, y: -525)
        tutorialButton.alpha = 1
        tutorialButton.zPosition = 10
        addChild(tutorialButton)
    }
    
    func appStorePage() {
        let url = Self.appStoreLink
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.canOpenURL(url!)
        }
    }
    
    func showTutorialScene() {
        let tutorialScene = GameScene(fileNamed: "Controls")
        tutorialScene!.scaleMode = .aspectFill
        let fade = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(tutorialScene!, transition: fade)
    }
    
    func playBackgroundMusic(name: String) {
        if let backgroundMusic = childNode(withName: "backgroundMusic") {
            backgroundMusic.removeFromParent()
        }
        let music = SKAudioNode(fileNamed: name)
        music.name = "backgroundMusic"
        music.autoplayLooped = true
        addChild(music)
    }
}
