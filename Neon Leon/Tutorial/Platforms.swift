//
//  Tutorial.swift
//  Neon Leion
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2018 BD Creative. All rights reserved.
//

import Foundation
import SpriteKit

class Platforms: SKScene {
    
    override func didMove(to view: SKView) {
        let dimmer = SKSpriteNode(imageNamed: "Dimmer")
        dimmer.position = CGPoint(x: 768, y: 1218)
        dimmer.zPosition = -1
        addChild(dimmer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newScene = SKScene(fileNamed: "PowerUps")
        newScene!.scaleMode = .aspectFill
        let fade = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(newScene!, transition: fade)
    }
}
