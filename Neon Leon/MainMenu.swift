//
//  MainMenu.swift
//  Neon Leon
//
//  Created by BDabrowski on 12/26/17.
//  Copyright © 2017 BD Creative. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenu: SKScene {
    
    var playButton: Button!
    var reviewButton: Button!
    var noAdsButton: Button!
    var tutorialButton: Button!
    let lightBuzz = SKAction.playSoundFileNamed("NeonLightBuzz.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        setupNodes()
        run(lightBuzz)
    }
    
    func showGameScene() {
        let newScene = GameScene(fileNamed: "GameScene")
        newScene!.scaleMode = .aspectFill
        let reveal = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene!, transition: reveal)
    }
    
    func setupNodes() {
        playButton = Button(defaultButtonImage: "PlayButton_00000", activeButtonImage: "PlayButton_00024", buttonAction: showGameScene)
        playButton.position = CGPoint(x: 788, y: 854)
        playButton.alpha = 0.01
        playButton.zPosition = 10
        addChild(playButton)
        
        reviewButton = Button(defaultButtonImage: "ReviewStar_00000", activeButtonImage: "ReviewStar_00024", buttonAction: appStorePage)
        reviewButton.position = CGPoint(x: 438, y: 404)
        reviewButton.alpha = 0.01
        reviewButton.zPosition = 10
        addChild(reviewButton)
        
        noAdsButton = Button(defaultButtonImage: "NoAds_00000", activeButtonImage: "NoAds_00024", buttonAction: removeAds)
        noAdsButton.position = CGPoint(x: 1138, y: 404)
        noAdsButton.alpha = 0.01
        noAdsButton.zPosition = 10
        addChild(noAdsButton)
        
        tutorialButton = Button(defaultButtonImage: "Lightbulb_00030", activeButtonImage: "Lightbulb_00031", buttonAction: showTutorialScene)
        tutorialButton.position = CGPoint(x: 768, y: 510)
        tutorialButton.alpha = 0.01
        tutorialButton.zPosition = 10
        addChild(tutorialButton)
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
    
    func removeAds() {
        print("Put in remove ads code when you buy iTunes Connect")
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
