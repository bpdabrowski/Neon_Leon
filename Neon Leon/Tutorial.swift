//
//  Tutorial.swift
//  
//
//  Created by BDabrowski on 1/16/18.
//

import Foundation
import SpriteKit

class Tutorial: SKScene {
    
    override func didMove(to view: SKView) {
        let dimmer = SKSpriteNode(imageNamed: "Dimmer")
        dimmer.position = CGPoint(x: 768, y: 1218)
        addChild(dimmer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newScene = GameScene(fileNamed: "MainMenu")
        newScene!.scaleMode = .aspectFill
        let fade = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(newScene!, transition: fade)
    }
}
