//
//  MainMenu.swift
//  Neon Leion
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2018 BD Creative. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    
    var playButton: Button!
    var reviewButton: Button!
    var noAdsButton: Button!
    var tutorialButton: Button!
    var settingsButton: Button!
    var soundButton: Button!
    var restoreIAPButton: Button!
    var soundImage: SKSpriteNode!
    var restoreIAPImage: SKSpriteNode!
    let userDefaults = UserDefaults.standard
    var tutorialButtonImage: SKSpriteNode!
    let notification = UINotificationFeedbackGenerator()
    
    var settingsButtonSelected = false
    
    let gameViewController = GameViewController()
    
    override func didMove(to view: SKView) {
        setupNodes()
        
        if userDefaults.integer(forKey: "HIGHSCORE") <= 5 {
            tutorialButtonImage = childNode(withName: "Tutorial") as! SKSpriteNode
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
    
    func showGameScene() {
        let newScene = GameScene(fileNamed: "GameScene")
        newScene!.scaleMode = .aspectFill
        let reveal = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene!, transition: reveal)
    }
    
    func setupNodes() {
        playButton = Button(defaultButtonImage: "PlayButton_00000", activeButtonImage: "PlayButton_00024", buttonAction: showGameScene)
        playButton.position = CGPoint(x: 0, y: -150)
        playButton.alpha = 0.01
        playButton.zPosition = 10
        addChild(playButton)
        
        reviewButton = Button(defaultButtonImage: "ReviewStar_00000", activeButtonImage: "ReviewStar_00024", buttonAction: appStorePage)
        reviewButton.position = CGPoint(x: -385, y: -600)
        reviewButton.alpha = 0.01
        reviewButton.zPosition = 10
        addChild(reviewButton)
        
        noAdsButton = Button(defaultButtonImage: "NoAds_00000", activeButtonImage: "NoAds_00024", buttonAction: gameViewController.removeAds)
        noAdsButton.position = CGPoint(x: 385, y: -600)
        noAdsButton.alpha = 0.01
        noAdsButton.zPosition = 10
        addChild(noAdsButton)
        
        tutorialButton = Button(defaultButtonImage: "SmallButtonCircle", activeButtonImage: "SmallButtonCircle", buttonAction: showTutorialScene)
        tutorialButton.position = CGPoint(x: 0, y: -505)
        tutorialButton.alpha = 0.01
        tutorialButton.zPosition = 10
        addChild(tutorialButton)
        
        restoreIAPButton = Button(defaultButtonImage: "SmallButtonCircle", activeButtonImage: "SmallButtonCircle", buttonAction: gameViewController.restorePurchases)
        restoreIAPButton.position = CGPoint(x: 0, y: -705)
        restoreIAPButton.alpha = 0.01
        restoreIAPButton.zPosition = 10
        addChild(restoreIAPButton)
    }
    
    func appStorePage() {
        let url = URL(string: "itms://itunes.apple.com/us/app/neon-leion/id1352620219?ls=1&mt=8")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.canOpenURL(url!)
        }
    }
    
    func showTutorialScene() {
        let tutorialScene = GameScene(fileNamed: "Tutorial")
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
