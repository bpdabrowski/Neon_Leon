//
//  GameEnvironment.swift
//  Neon Leon
//
//  Created by Brendyn Dabrowski on 11/5/22.
//  Copyright © 2022 BD Creative. All rights reserved.
//

import Foundation
import SpriteKit

class GameEnvironment {
    
    var bgNode: SKNode!
    var fgNode: SKNode!
    var backgroundOverlayTemplate: SKNode!
    var backgroundOverlayHeight: CGFloat!
    var startPlatform: SKSpriteNode!
    var level1: SKSpriteNode!
    var level2: SKSpriteNode!
    var level3: SKSpriteNode!
    var level4: SKSpriteNode!
    var level5: SKSpriteNode!
    var level6: SKSpriteNode!
    var level7: SKSpriteNode!
    var level8: SKSpriteNode!
    var level9: SKSpriteNode!
    var level10: SKSpriteNode!
    var level11: SKSpriteNode!
    var startPlatformAnimation: SKAction!
    var lastOverlayPosition = CGPoint.zero
    var lastOverlayHeight: CGFloat = 0.0
    var levelPositionY: CGFloat = 0.0
    var lava: SKSpriteNode!
    static let playerAndInvincibleContactMask: UInt32 = 4097
    
    init() {
        setupNodes()
        setupLevel()
    }
    
    func setupNodes() {
        let worldNode = childNode(withName: "World")!
        bgNode = worldNode.childNode(withName: "Background")!
        backgroundOverlayTemplate = bgNode.childNode(withName: "Overlay")!.copy() as? SKNode
        backgroundOverlayHeight = backgroundOverlayTemplate.calculateAccumulatedFrame().height
        fgNode = worldNode.childNode(withName: "Foreground")!
//        player = fgNode.childNode(withName: "Player") as? NeonLeon
        
        startPlatform = loadForegroundOverlayTemplate("StartPlatform")
        level1 = loadForegroundOverlayTemplate("Level1")
        level2 = loadForegroundOverlayTemplate("Level2")
        level3 = loadForegroundOverlayTemplate("Level3")
        level4 = loadForegroundOverlayTemplate("Level4")
        level5 = loadForegroundOverlayTemplate("Level5")
        level6 = loadForegroundOverlayTemplate("Level6")
        level7 = loadForegroundOverlayTemplate("Level7")
        level8 = loadForegroundOverlayTemplate("Level8")
        level9 = loadForegroundOverlayTemplate("Level9")
        level10 = loadForegroundOverlayTemplate("Level10")
        level11 = loadForegroundOverlayTemplate("Level11")
        
        setupLava()
        setupBackground("Background.sks")
    }
    
    func setupLevel() {
        // Place initial platform
        let initialPlatform = startPlatform.copy() as! SKSpriteNode
        startPlatformAnimation = SKAction.animate(withPrefix: "StartPlatform_000",
                                                  start: 1,
                                                  end: 30,
                                                  timePerFrame: 0.05)
        
        initialPlatform.size = CGSize(width: 1536, height: 300)
        initialPlatform.zPosition = 1
        
        var overlayPosition = CGPoint(x: 0, y: 0)
        
        //Made platform height up to match the anchor point of the player.
        //Changed ((player.size.height * 0.5) to ((player.size.height * 0.316)
        overlayPosition.y = -120
        initialPlatform.position = CGPoint(x: 0, y: 0)
        fgNode.addChild(initialPlatform)
        initialPlatform.isPaused = false
        initialPlatform.run(SKAction.repeatForever(startPlatformAnimation))
        lastOverlayPosition = overlayPosition
        lastOverlayHeight = initialPlatform.size.height / 2.0
        
        // Create random level
        levelPositionY = bgNode.childNode(withName: "Overlay")!
            .position.y + backgroundOverlayHeight
        while lastOverlayPosition.y < levelPositionY {
            addRandomForegroundOverlay()
        }
    }
    
    func addRandomForegroundOverlay() {
        let overlaySprite: SKSpriteNode!
        var flipH = false
        let platformPercentage = 100
        
        if Int.random(min: 1, max: 100) <= platformPercentage {
            if Int.random(min: 1, max: 100) <= 75 {
                // Create standard platforms 75%
                switch Int.random(min: 0, max: 19) {
                case 0:
                    overlaySprite = level1
                case 1:
                    overlaySprite = level1
                    flipH = true
                case 2:
                    overlaySprite = level2
                case 3:
                    overlaySprite = level2
                    flipH = true
                case 4:
                    overlaySprite = level3
                case 5:
                    overlaySprite = level3
                    flipH = true
                case 6:
                    overlaySprite = level4
                case 7:
                    overlaySprite = level4
                    flipH = true
                case 8:
                    overlaySprite = level5
                case 9:
                    overlaySprite = level5
                    flipH = true
                case 10:
                    overlaySprite = level6
                case 11:
                    overlaySprite = level6
                    flipH = true
                case 12:
                    overlaySprite = level7
                case 13:
                    overlaySprite = level7
                    flipH = true
                case 14:
                    overlaySprite = level8
                case 15:
                    overlaySprite = level8
                    flipH = true
                case 16:
                    overlaySprite = level9
                case 17:
                    overlaySprite = level9
                    flipH = true
                case 18:
                    overlaySprite = level10
                case 19:
                    overlaySprite = level10
                    flipH = true
                default:
                    overlaySprite = level1
                }
                
                createForegroundOverlay(overlaySprite, flipX: flipH)
            }
        }
    }
    
    func createForegroundOverlay(_ overlayTemplate: SKSpriteNode, flipX: Bool) {
        let foregroundOverlay = overlayTemplate.copy() as! SKSpriteNode
        lastOverlayPosition.y = lastOverlayPosition.y +
            (lastOverlayHeight + (foregroundOverlay.size.height / 2.0))
        lastOverlayHeight = foregroundOverlay.size.height / 2.0
        foregroundOverlay.position = lastOverlayPosition
        if flipX == true {
            foregroundOverlay.xScale = -1.0
        }
        addAnimationToOverlay(overlay: foregroundOverlay)
        fgNode.addChild(foregroundOverlay)

        foregroundOverlay.isPaused = false
    }
    
    func loadForegroundOverlayTemplate(_ fileName: String) -> SKSpriteNode {
        let overlayScene = SKScene(fileNamed: fileName)!
        let overlayTemplate = overlayScene.childNode(withName: "Overlay")
        return overlayTemplate as! SKSpriteNode
    }
    
    func setupBackground(_ fileName: String) -> SKEmitterNode {
        let emitter = SKEmitterNode(fileNamed: fileName)!
        emitter.particlePositionRange = CGVector(dx: size.width * 1.125, dy: size.height * 2)
        emitter.advanceSimulationTime(3.0)
//        camera?.addChild(emitter)
        return emitter
    }
    
    func setupLava() {
        lava = fgNode.childNode(withName: "Lava") as? SKSpriteNode
    }
    
    func addAnimationToOverlay(overlay: SKSpriteNode) {
        overlay.enumerateChildNodes(withName: "SpikeOutline") { (node, stop) in
            let newNode = SKSpriteNode()
            let spikeBodyTexture = SKTexture(imageNamed: "SpikeOutline")
            newNode.physicsBody = SKPhysicsBody(texture: spikeBodyTexture, size: CGSize(width: 190, height: 100))
            newNode.physicsBody = self.physicsBodySettings(for: newNode.physicsBody!)
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.Spikes
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player

            newNode.position = node.position
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "NSPlatformLow") { (node, stop) in
            var newNode = SKSpriteNode()
//            self.blueNSPlatformAnimation = SKAction.animate(withPrefix: "BluePlatformNS_000",
//                                                            start: 30,
//                                                            end: 45,
//                                                            timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "BluePlatformNS_00030")
            newNode.size = CGSize(width: 350, height: 216)
            newNode.zPosition = 1
            newNode.position = node.position
    
            newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 117, height: 90))
            newNode.physicsBody?.isDynamic = false
            newNode.physicsBody?.affectedByGravity = false
            newNode.physicsBody?.allowsRotation = false
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.BackupLow
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Invincible
    
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "PlatformMid") { (node, stop) in
            var newNode = SKSpriteNode()
            newNode = SKSpriteNode(imageNamed: "YellowPlatformLt_0000")
            newNode.run(SKAction.repeatForever(SKAction.animate(withPrefix: "YellowPlatformLt_000",
                                                                start: 00,
                                                                end: 30,
                                                                timePerFrame: 0.02)))
            newNode.size = CGSize(width: 350, height: 216)
            newNode.zPosition = 1
            newNode.position = node.position
            
            newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 117, height: 90))
            newNode.physicsBody?.isDynamic = false
            newNode.physicsBody?.affectedByGravity = false
            newNode.physicsBody?.allowsRotation = false
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.BackupMiddle
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Invincible
            
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "PlatformHigh") { (node, stop) in
            var newNode = SKSpriteNode()
            newNode = SKSpriteNode(imageNamed: "PinkPlatformLt_00030")
            newNode.run(SKAction.repeatForever(SKAction.animate(withPrefix: "PinkPlatformLt_000",
                                                                start: 30,
                                                                end: 60,
                                                                timePerFrame: 0.02)))
            newNode.size = CGSize(width: 350, height: 216)
            newNode.zPosition = 1
            newNode.position = node.position
            
            newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 117, height: 90))
            newNode.physicsBody?.isDynamic = false
            newNode.physicsBody?.affectedByGravity = false
            newNode.physicsBody?.allowsRotation = false
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.BackupHigh
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Invincible
            
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "PlatformLow") { (node, stop) in
            var newNode = SKSpriteNode()
            newNode = SKSpriteNode(imageNamed: "BluePlatformLt_00015")
            newNode.run(SKAction.repeatForever(SKAction.animate(withPrefix: "BluePlatformLt_000",
                                                                start: 15,
                                                                end: 45,
                                                                timePerFrame: 0.02)))
            newNode.size = CGSize(width: 350, height: 216)
            newNode.zPosition = 1
            newNode.position = node.position
            
            newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 117, height: 90))
            newNode.physicsBody?.isDynamic = false
            newNode.physicsBody?.affectedByGravity = false
            newNode.physicsBody?.allowsRotation = false
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.BackupLow
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Invincible
            
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "PlatformMid") { (node, stop) in
            var newNode = SKSpriteNode()
            newNode = SKSpriteNode(imageNamed: "YellowPlatformLt_0000")
            newNode.run(SKAction.repeatForever(SKAction.animate(withPrefix: "YellowPlatformLt_000",
                                                                start: 00,
                                                                end: 30,
                                                                timePerFrame: 0.02)))
            newNode.size = CGSize(width: 350, height: 216)
            newNode.zPosition = 1
            newNode.position = node.position
            
            newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 117, height: 90))
            newNode.physicsBody?.isDynamic = false
            newNode.physicsBody?.affectedByGravity = false
            newNode.physicsBody?.allowsRotation = false
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.BackupMiddle
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Invincible
            
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "PlatformHigh") { (node, stop) in
            var newNode = SKSpriteNode()
            newNode = SKSpriteNode(imageNamed: "PinkPlatformLt_00030")
            newNode.run(SKAction.repeatForever(SKAction.animate(withPrefix: "PinkPlatformLt_000",
                                                                start: 30,
                                                                end: 60,
                                                                timePerFrame: 0.02)))
            newNode.size = CGSize(width: 350, height: 216)
            newNode.zPosition = 1
            newNode.position = node.position
            
            newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 117, height: 90))
            newNode.physicsBody?.isDynamic = false
            newNode.physicsBody?.affectedByGravity = false
            newNode.physicsBody?.allowsRotation = false
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.BackupHigh
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Invincible
            
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
       
        overlay.enumerateChildNodes(withName: "PlatformDead") { (node, stop) in
            let newNode = SKSpriteNode()
            newNode.run(SKAction.repeatForever(SKAction.animate(withPrefix: "DeadPlatformLt_000",
                                                                start: 0,
                                                                end: 30,
                                                                timePerFrame: 0.02)))
            newNode.size = CGSize(width: 350, height: 250)
            newNode.zPosition = 1
            newNode.position = node.position
            newNode.anchorPoint = CGPoint(x: 0.5, y: 0.42)
            
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "Mouse") { (node, stop) in
            var newNode = SKSpriteNode()
            let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 20), duration: 0.5)
            let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -20), duration: 0.5)
            let moveSequence = SKAction.sequence([moveUp, moveDown])
            newNode = SKSpriteNode(imageNamed: "Mouse_00000")
            
            newNode.run(SKAction.repeatForever(moveSequence))
            newNode.size = CGSize(width: 125, height: 107)
            newNode.zPosition = 1
            newNode.position = node.position
            overlay.addChild(newNode)
            
            newNode.physicsBody = SKPhysicsBody(circleOfRadius: newNode.size.width / 4)
            newNode.physicsBody?.isDynamic = false
            newNode.physicsBody?.affectedByGravity = false
            newNode.physicsBody?.allowsRotation = false
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.Mouse
            newNode.physicsBody!.contactTestBitMask = Self.playerAndInvincibleContactMask

            node.removeFromParent()
        }
    }
    
    func updateLevel() {
        let cameraPos = camera!.position
        if cameraPos.y > levelPositionY - (size.height * 0.55) {
            createBackgroundOverlay()
            while lastOverlayPosition.y < levelPositionY {
                addRandomForegroundOverlay()
            }
        }
        // remove old foreground nodes
        for fgChild in fgNode.children {
            let nodePos = fgNode.convert(fgChild.position, to: self)
            if !isNodeVisible(fgChild, positionY: nodePos.y) {
                fgChild.removeFromParent()
            }
        }
    }
    
    func createBackgroundOverlay() {
        let backgroundOverlay = backgroundOverlayTemplate.copy() as! SKNode
        backgroundOverlay.position = CGPoint(x: 0.0, y: levelPositionY)
        bgNode.addChild(backgroundOverlay)
        levelPositionY += backgroundOverlayHeight
    }
    
    func physicsBodySettings(for physicsBody: SKPhysicsBody) -> SKPhysicsBody {
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        return physicsBody
    }

}
