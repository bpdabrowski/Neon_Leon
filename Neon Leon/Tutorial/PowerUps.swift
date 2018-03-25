//
//  Tutorial.swift
//  Neon Leion
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2018 BD Creative. All rights reserved.
//

import Foundation
import SpriteKit

class PowerUps: SKScene {
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var fallTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        let dimmer = SKSpriteNode(imageNamed: "Dimmer")
        dimmer.position = CGPoint(x: 768, y: 1218)
        dimmer.zPosition = -1
        addChild(dimmer)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newScene = GameScene(fileNamed: "Hazards")
        newScene!.scaleMode = .aspectFill
        let fade = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(newScene!, transition: fade)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        lastUpdateTimeInterval = currentTime
        
        fallingLightning(deltaTime)
    }
    
    func fallingLightning(_ dt: TimeInterval) {
        fallTime += dt
        
        let powerUpBullet = SKSpriteNode(imageNamed: "Lightning_0028")
        
        powerUpBullet.position = CGPoint(
            x: random(min: 100, max: 500),
            y: self.size.height + 768)
        
        powerUpBullet.zPosition = 2
        powerUpBullet.yScale = 0.75
        powerUpBullet.xScale = 0.75
        
        if fallTime >= 0.25 {
            addChild(powerUpBullet)
            fallTime = 0
        }
        
        let moveVector = CGVector(dx: 0, dy: -3000)
        let powerUpBulletMoveAction = SKAction.move(by: moveVector, duration: 4.0)
        let powerUpBulletRepeat = SKAction.repeatForever(powerUpBulletMoveAction)
        powerUpBullet.run(powerUpBulletRepeat)
        
        powerUpBullet.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi/4.0, duration: 0.25)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            powerUpBullet.removeFromParent()
        })
        
    }
    
}
