//
//  MainMenu.swift
//  Neon Leon
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2017 BD Creative. All rights reserved.
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
        
        /*settingsButton = Button(defaultButtonImage: "SmallButtonCircle", activeButtonImage: "SmallButtonCircle", buttonAction: showSettings)
        settingsButton.position = CGPoint(x: 0, y: -705)
        settingsButton.alpha = 0.01
        settingsButton.zPosition = 10
        addChild(settingsButton)*/
    }
    
    func appStorePage() {
        let url = URL(string: "itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8")
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
    
    func showSettings() {
        //Setup Buttons
        //If settings button hasn't been pressed, flyout the settings. If it has bring them back in.
        
        let flyOutSound = SKAction.move(by: CGVector(dx: 150, dy: -145), duration: 0.25)
        let flyInSound = SKAction.move(by: CGVector(dx: -150, dy: 145), duration: 0.25)
        let flyOutRestore = SKAction.move(by: CGVector(dx: -150, dy: -145), duration: 0.25)
        let flyInRestore = SKAction.move(by: CGVector(dx: 150, dy: 145), duration: 0.25)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        
        restoreIAPImage = childNode(withName: "RestoreIAP") as! SKSpriteNode
        soundImage = childNode(withName: "Sound") as! SKSpriteNode
        
        if settingsButtonSelected == false {
            settingsButtonSelected = true
            soundButton = Button(defaultButtonImage: "SmallButtonCircle", activeButtonImage: "SmallButtonCircle", buttonAction: gameViewController.toggleSound)
            soundButton.position = CGPoint(x: 150, y: -850)
            soundButton.alpha = 0.01
            soundButton.zPosition = 10
            addChild(soundButton)
            
            restoreIAPButton = Button(defaultButtonImage: "SmallButtonCircle", activeButtonImage: "SmallButtonCircle", buttonAction: gameViewController.restorePurchases)
            restoreIAPButton.position = CGPoint(x: -150, y: -850)
            restoreIAPButton.alpha = 0.01
            restoreIAPButton.zPosition = 10
            addChild(restoreIAPButton)
            
            let flyOutSoundGroup = SKAction.group([flyOutSound,fadeIn])
            let flyOutRestoreGroup = SKAction.group([flyOutRestore,fadeIn])
            
            soundImage?.run(flyOutSoundGroup)
            restoreIAPImage?.run(flyOutRestoreGroup)
            
        } else if settingsButtonSelected == true {
            let flyInSoundGroup = SKAction.group([flyInSound,fadeOut])
            let flyInRestoreGroup = SKAction.group([flyInRestore,fadeOut])
            
            soundImage?.run(flyInSoundGroup)
            restoreIAPImage?.run(flyInRestoreGroup)
            
            settingsButtonSelected = false
            soundButton.removeFromParent()
            restoreIAPButton.removeFromParent()
            print(settingsButtonSelected)
        }
    }
}
