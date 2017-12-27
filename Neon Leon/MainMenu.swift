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
    //var gameScene: GameScene!
    
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    func showGameScene() {
        let newScene = GameScene(fileNamed: "GameScene")
        newScene!.scaleMode = .aspectFill
        let reveal = SKTransition.fade(withDuration: 1.0)//SKTransition.flipHorizontal(withDuration: 0.5)
        self.view?.presentScene(newScene!, transition: reveal)
    }
    
    func setupNodes() {
        playButton = Button(defaultButtonImage: "PlayButton_00000", activeButtonImage: "PlayButton_00024", buttonAction: showGameScene)
        playButton.position = CGPoint(x: 788, y: 854)//(x: 0, y: -150)
        playButton.alpha = 0.01
        playButton.zPosition = 10
        addChild(playButton)
    }
    
}
