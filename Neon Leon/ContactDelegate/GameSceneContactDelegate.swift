//
//  PlatformContactDelegate.swift
//  Neon Leon
//
//  Created by Brendyn Dabrowski on 11/5/22.
//  Copyright © 2022 BD Creative. All rights reserved.
//

import Foundation
import SpriteKit

struct PhysicsCategory {
    static let None: UInt32                 = 0
    static let Player: UInt32               = 0b1 // 1
    static let PlatformMiddle: UInt32       = 0b10 // 2
    static let BackupLow: UInt32            = 0b100 // 4
    static let Lava: UInt32                 = 0b1000 // 8
    static let powerUp: UInt32              = 0b10000 // 16
    static let BackupMiddle: UInt32         = 0b100000 // 32
    static let BackupHigh: UInt32           = 0b1000000 // 64
    static let Mouse: UInt32                = 0b10000000 // 128
    static let Spikes: UInt32               = 0b100000000 // 256
    static let PlatformHigh: UInt32         = 0b1000000000 // 512
    static let PlatformLow: UInt32          = 0b10000000000 // 1024
    static let NoSpikePlatform: UInt32      = 0b100000000000 // 2048
    static let Invincible: UInt32           = 0b1000000000000 // 4096
}

class GameSceneContactDelegate: NSObject, SKPhysicsContactDelegate {
    
    // tokens, obstacles, platforms
    private let player: NeonLeon
    private var updatePlatformState: ((PlatformStatus) -> Void)
    private var onPlatform = false
    
    init(player: NeonLeon, updatePlatformState: @escaping ((PlatformStatus) -> Void)) {
        self.player = player
        self.updatePlatformState = updatePlatformState
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.powerUp:
//                emitParticles(name: "LightningExplode", sprite: powerUpBullet)
                player.setInvincible()
//                lightningOff.run(self.playLightningAnimation(timePerFrame: 0.035))
//                notification.notificationOccurred(.warning)
//                powerUpBullet.removeFromParent()
            
        case PhysicsCategory.PlatformLow:
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    player.onPlatformSettings()
                    updatePlatformState(.low)
//                    emitParticles(name: "OneArrow", sprite: platform)
                    onPlatform = true
                    platform.removeFromParent()
//                    score += 1
                }
            }
            
        case PhysicsCategory.PlatformMiddle:
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    player.onPlatformSettings()
                    updatePlatformState(.middle)
//                    emitParticles(name: "TwoArrows", sprite: platform)
                    platform.removeFromParent()
//                    score += 1
                }
            }
            
        case PhysicsCategory.PlatformHigh:
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    player.onPlatformSettings()
                    updatePlatformState(.high)
//                    emitParticles(name: "ThreeArrows", sprite: platform)
                    platform.removeFromParent()
//                    score += 1
                }
            }
            
        case PhysicsCategory.BackupLow:
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    player.onPlatformSettings()
                    updatePlatformState(.low)
//                    emitParticles(name: "OneArrow", sprite: platform)
                    onPlatform = true
                }
            }
            
        case PhysicsCategory.BackupMiddle:
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    player.onPlatformSettings()
                    updatePlatformState(.middle)
//                    emitParticles(name: "TwoArrows", sprite: platform)
                }
            }
            
        case PhysicsCategory.BackupHigh:
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    player.onPlatformSettings()
                    updatePlatformState(.high)
//                    emitParticles(name: "ThreeArrows", sprite: platform)
                }
            }
            
//        case PhysicsCategory.Spikes:
//            notification.notificationOccurred(.error)
//            if !self.isInvincible {
//                self.subtractLife()
//            }
//            run(electricute)
//            
//        case PhysicsCategory.Lava:
//            if !self.isInvincible {
//                self.subtractLife()
//                run(electricute)
//            } else if self.isInvincible {
//                superBoostPlayer()
//                run(soundJump)
//            }
            
        default:
            break
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let other: SKPhysicsBody?

        if contact.bodyA.categoryBitMask == PhysicsCategory.Player || contact.bodyA.categoryBitMask == PhysicsCategory.Invincible {
            other = contact.bodyB
        } else {
            other = contact.bodyA
        }

        switch other?.categoryBitMask {
        case PhysicsCategory.Mouse:
            break
//            if let mouse = other?.node as? SKSpriteNode {
//                emitParticles(name: "MouseExplode", sprite: mouse)
//                run(mouseHit)
//                score += 2
//                mouse.removeFromParent()
//            }

        default:
            break
        }
    }
}
