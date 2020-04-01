//
//  Tutorial.swift
//  Neon Leion
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2018 BD Creative. All rights reserved.
//

import Foundation
import SpriteKit

class Hazards: SKScene {
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    var fallTime: TimeInterval = 0

    public static let tutorialDoneNotification = Notification.Name("tutorialDone")
    
    override func didMove(to view: SKView) {
        let dimmer = SKSpriteNode(imageNamed: "Dimmer")
        dimmer.position = CGPoint(x: 768, y: 1218)
        dimmer.zPosition = -1
        addChild(dimmer)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let newScene = GameScene(fileNamed: "GameScene")
        newScene!.scaleMode = .aspectFill
        NotificationCenter.default.post(name: Self.tutorialDoneNotification, object: nil)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        lastUpdateTimeInterval = currentTime
        
        fallingFish(deltaTime)
    }
    
    func fallingFish(_ dt: TimeInterval) {
        fallTime += dt
        
        let fishBullet = SKSpriteNode(imageNamed: "DeadFish_00015")
        
        fishBullet.position = CGPoint(
            x: random(min: 100, max: 500),
            y: self.size.height + 768)
        
        fishBullet.zPosition = 2
        fishBullet.yScale = 0.5
        fishBullet.xScale = 0.5
        
        if fallTime >= 0.25 {
            addChild(fishBullet)
            fallTime = 0
        }
        
        let moveVector = CGVector(dx: 0, dy: -3000)
        let fishBulletMoveAction = SKAction.move(by: moveVector, duration: 4.0)
        let fishBulletRepeat = SKAction.repeatForever(fishBulletMoveAction)
        fishBullet.run(fishBulletRepeat)
        
        fishBullet.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi/4.0, duration: 0.25)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            fishBullet.removeFromParent()
        })
        
    }
}
