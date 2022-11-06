//
//  NeonLeon.swift
//  Neon Leon
//
//  Created by Brendyn Dabrowski on 11/5/22.
//  Copyright © 2022 BD Creative. All rights reserved.
//

import Foundation
import SpriteKit

enum PlayerState: Int {
    case idle = 0
    case jump = 1
    case fall = 2
    case lava = 3
}

class NeonLeon: SKSpriteNode {
    
    private(set) var state: PlayerState = .idle
    var invincibleTime: TimeInterval = 0
    var isInvincible: Bool {
        return physicsBody?.categoryBitMask == 4096
    }
    
    func setupPhysicsBody() {
        physicsBody = SKPhysicsBody(circleOfRadius: 60, center: CGPoint(x: 0.5, y: 0.25))
        physicsBody?.isDynamic = false
        physicsBody?.allowsRotation = false
        physicsBody?.categoryBitMask = PhysicsCategory.Player //Invincible
        physicsBody?.collisionBitMask = PhysicsCategory.NoSpikePlatform
        physicsBody?.restitution = 0
        physicsBody?.affectedByGravity = false //DEBUG - Turned off player gravity
        physicsBody?.linearDamping = 1.0
        physicsBody?.friction = 1.0
    }
    
    func update(playerState: PlayerState) {
        self.state = playerState
    }
    
    func onPlatformSettings() {
        // When this is turned off, the player doesn't jump to the correct height
        physicsBody?.isDynamic = true
        physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        physicsBody?.affectedByGravity = false
        update(playerState: .idle)
    }
    
    func move(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let parent = parent, state != .idle {
            let touch = touches.first
            let touchLocation = touch!.location(in: parent)
            let previousLocation = touch!.previousLocation(in: parent)
            let touchDifference = touchLocation.x - previousLocation.x
            let catX = position.x + ((touchDifference) * 1.25)
            position = CGPoint(x: catX, y: position.y)
            
            if touchDifference <= 0 {
                xScale = -abs(xScale)
            } else {
                xScale = abs(xScale)
            }
        }
    }
    
    func jump(platformState: PlatformStatus) {
        if state == .idle {
            switch platformState {
            case .none:
                break
            case .low:
                jumpPlayer()
            case .middle:
                boostPlayer()
            case .high:
                superBoostPlayer()
            }
        }
    }
    
    private func jumpPlayer() {
        physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 550))
    }
    
    private func boostPlayer() {
        physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 850))
    }
    
    func superBoostPlayer() {
        physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 1100))
    }
    
    func start() {
        update(playerState: .idle)
        physicsBody!.isDynamic = true
    }
    func dead() {
        physicsBody?.isDynamic = false
        run(SKAction.animate(withPrefix: "NLCat_Off_", start: 1, end: 7, timePerFrame: 0.05))
        
         let wait = SKAction.wait(forDuration: 0.3)
         let moveUp = SKAction.moveBy(x: 0.0, y: 200, duration: 0.2)
         moveUp.timingMode = .easeOut
         let moveDown = SKAction.moveBy(x: 0.0,
                                        y: -(size.height * 1.5),
                                        duration: 1.0)
        moveDown.timingMode = .easeIn
        run(SKAction.sequence([wait, moveUp, moveDown]))
    }
    
    func handleRecoveryPeriod() {
        physicsBody?.categoryBitMask = PhysicsCategory.Invincible
        run(SKAction.animate(withPrefix: "NLCat_Off_", start: 1, end: 5, timePerFrame: 0.15))

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] timer in
            self?.physicsBody?.categoryBitMask = PhysicsCategory.Player
            timer.invalidate()
        }

        boostPlayer()
    }
    
    private func playJumpingAnimation() {
        guard let physicsBody = physicsBody else {
            return
        }
        
        let playerVerticalVelocity = physicsBody.velocity.dy
        if playerVerticalVelocity < CGFloat(0.0) && state != .fall {
            update(playerState: .fall)
        } else if playerVerticalVelocity > CGFloat(0.0) && state != .jump {
            update(playerState: .jump)
        }
        
        // Animate player
        switch state {
        case .jump:
            if abs(playerVerticalVelocity) > 100.0 {
                let playerAnimationJump = SKAction.animate(withPrefix: "NLCat_Jump_", start: 1, end: 4, timePerFrame: 0.025)
                self.runPlayerAnimation(playerAnimationJump)
            }
        case .fall:
            let playerAnimationFall = SKAction.animate(withPrefix: "NLCat_Fall_", start: 1, end: 6, timePerFrame: 0.025)
            self.runPlayerAnimation(playerAnimationFall)
        case .idle:
            let playerAnimationPlatform = SKAction.animate(withPrefix: "NLCat_Platform_", start: 1, end: 4, timePerFrame: 0.025)
            self.runPlayerAnimation(playerAnimationPlatform)
        case .lava:
            break
        }
    }
        
    func runPlayerAnimation(_ animation: SKAction) {
        removeAction(forKey: "playerAnimation")
        run(animation, withKey: "playerAnimation")
    }
    
    func update(_ dt: TimeInterval) {
        if state != .idle {
            physicsBody?.affectedByGravity = true
        }
        playJumpingAnimation()
        updateInvincibility(dt)
    }
    
    func addTrail(name: String) {
        let trail = SKEmitterNode(fileNamed: name)!
        trail.zPosition = -1
        trail.position = CGPoint(x: -100, y: 0)
        trail.targetNode = parent!
        addChild(trail)
    }
    
    private func updateInvincibility(_ dt: TimeInterval) {
        if isInvincible && invincibleTime < 7 {
            invincibleTime += dt
            if childNode(withName: "InvincibleTrail") == nil {
                addTrail(name: "InvincibleTrail")
            }
            
        } else if isInvincible {
            physicsBody?.categoryBitMask = PhysicsCategory.Player
            invincibleTime = 0
            removeAllChildren()
        }
    }
    
    func setInvincible() {
        if !isInvincible {
            physicsBody?.categoryBitMask = PhysicsCategory.Invincible
            run(SKAction.playSoundFileNamed("PowerUp.wav", waitForCompletion: false))
        }
    }
}
