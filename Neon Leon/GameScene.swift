//
//  GameScene.swift
//  Neon Leion
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2018 BD Creative. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

// MARK: - Game States
enum GameStatus: Int {
    case waitingForTap = 0
    case playing = 1
    case gameOver = 2
}

enum PlatformStatus: Int {
    case none = 0
    case low = 1
    case middle = 2
    case high = 3
}

class GameScene: SKScene {
    
    // MARK: - Properties
    var player: NeonLeon!
    
    var gameState = GameStatus.waitingForTap
    var platformState = PlatformStatus.none
    
    let cameraNode = SKCameraNode()
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    
    var lives: Int?
    
    let soundBoost = SKAction.playSoundFileNamed("boost.wav", waitForCompletion: false)
    let soundJump = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    let soundCoin = SKAction.playSoundFileNamed("coin1.wav", waitForCompletion: false)
    let mouseHit = SKAction.playSoundFileNamed("CoinCollect.mp3", waitForCompletion: false)
    
    let electricute = SKAction.playSoundFileNamed("GameOver.mp3", waitForCompletion: false)
    
    let scoreLabel = SKLabelNode(fontNamed: "NeonTubes2-Regular")
    var score = 0
    var highScore = UserDefaults().integer(forKey: "HIGHSCORE")
    
    var deadFishTimeSinceLastShot: TimeInterval = 0
    var powerUpTimeSinceLastShot: TimeInterval = 0
    var deadFishNextShot: TimeInterval = 1.0
    var powerUpNextShot: TimeInterval = 1.0
    
    var selectedNodes:[UITouch:SKSpriteNode] = [:]
    var reviewButton: Button!
    var noAdsStart: Button!
    var tutorialButton: Button!
    
    var lightningOff: SKSpriteNode!
    var lightningOff2: SKSpriteNode!
    var lightningOff3: SKSpriteNode!
    
    var lightningTrapAnimation: SKAction!
    var deadFishAnimation: SKAction!
    let userDefaults = UserDefaults.standard
    
    var powerUpBullet: SKSpriteNode!
    var deadFishBullet: SKSpriteNode!
    
    var animationLoopDown: SKAction!
    var wait1: SKAction!
    var wait2: SKAction!
    var wait3: SKAction!
    var wait5: SKAction!
    
    var pointerHand: SKSpriteNode! = nil
    
    let notification = UINotificationFeedbackGenerator()
    var lifeNode1: SKSpriteNode!
    
    var lifeNode2: SKSpriteNode!
    
    var gameOverAction: ((Int) -> Void)?
    
    private var contactDelegate: SKPhysicsContactDelegate?
    
    override func didMove(to view: SKView) {
        view.showsPhysics = true
        self.setupGameScene()
    }
    
    func setupGameScene() {
        let gameEnvironment = GameEnvironment()
        addChild(cameraNode)
        camera = cameraNode

        player.setupPhysicsBody()
        
        let updatePlatformState: ((PlatformStatus) -> Void) = { [weak self] platformState in
            self?.platformState = platformState
        }
        self.contactDelegate = GameSceneContactDelegate(player: player, updatePlatformState: updatePlatformState)
        physicsWorld.contactDelegate = contactDelegate
        
        camera?.position = CGPoint(x: size.width/2, y: size.height/2)
        
        lightningOff = SKSpriteNode(imageNamed: "Lightning_00000")
        lightningOff.size = CGSize(width: 375, height: 390)
        lightningOff.zPosition = 4
        lightningOff.position = CGPoint(x: -450, y: 900)
        camera?.addChild(lightningOff)
        
        animationLoopDown = SKAction.animate(withPrefix: "Lightning_00",
                                             start: 1,
                                             end: 201,
                                             timePerFrame: 0.035)
        
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 200
        scoreLabel.zPosition = 8
        scoreLabel.position = CGPoint(x: 0, y: 825)
        camera?.addChild(scoreLabel)
        
        self.createLivesTracker()
    }
    
    private func createLivesTracker() {
        let lifeNode1 = self.createNode(with: SKTexture(image: #imageLiteral(resourceName: "Lightning_0035")))
        lifeNode1.position = CGPoint(x: 400, y: 900)
        self.lifeNode1 = lifeNode1
        
        let lifeNode2 = self.createNode(with: SKTexture(image: #imageLiteral(resourceName: "Lightning_0035")))
        lifeNode2.position = CGPoint(x: 475, y: 900)
        self.lifeNode2 = lifeNode2
        
        self.lifeNode1.isHidden = true
        self.lifeNode2.isHidden = true
    }
    
    private func createNode(with texture: SKTexture) -> SKSpriteNode {
        let node = SKSpriteNode(texture: texture)
        node.zPosition = 4
        node.size = CGSize(width: 375, height: 390)
        node.xScale = 0.5
        node.yScale = 0.5
        self.camera?.addChild(node)
        return node
    }
    
    func spawnPowerUp(moveDuration: TimeInterval) {
        powerUpBullet = SKSpriteNode(imageNamed: "Lightning_0028")
        powerUpBullet.position = CGPoint(
            x: random(min: 300, max: 500),
            y: self.size.height + camera!.position.y - 768)
        
        powerUpBullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 128, height: 128))
        powerUpBullet.physicsBody?.affectedByGravity = false
        powerUpBullet.physicsBody?.isDynamic = false
        powerUpBullet.physicsBody?.allowsRotation = true
        powerUpBullet.physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        powerUpBullet.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        powerUpBullet.physicsBody?.collisionBitMask = 0
        powerUpBullet.zPosition = 6
        powerUpBullet.yScale = 0.75
        powerUpBullet.xScale = 0.75
        addChild(powerUpBullet)
        
        let moveVector = CGVector(dx: 0, dy: -3000)
        let powerUpBulletMoveAction = SKAction.move(by: moveVector, duration: moveDuration)
        let powerUpBulletRepeat = SKAction.repeatForever(powerUpBulletMoveAction)
        powerUpBullet.run(powerUpBulletRepeat)
        
        powerUpBullet.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi/4.0, duration: 0.25)))
        
        if !isNodeVisible(powerUpBullet, positionY: powerUpBullet.position.y) {
            powerUpBullet.removeFromParent()
        }
    }
    
    func spawnShooter(moveDuration: TimeInterval) {
        deadFishBullet = SKSpriteNode(imageNamed: "DeadFish_00015")
        
        deadFishBullet.position = CGPoint(
            x: random(min: 300, max: 500),
            y: self.size.height + camera!.position.y - 768)
        
        deadFishBullet.physicsBody = SKPhysicsBody(circleOfRadius: deadFishBullet.size.width/7)
        deadFishBullet.physicsBody?.affectedByGravity = false
        deadFishBullet.physicsBody?.isDynamic = false
        deadFishBullet.physicsBody?.allowsRotation = true
        deadFishBullet.physicsBody?.categoryBitMask = PhysicsCategory.Spikes
        deadFishBullet.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        deadFishBullet.physicsBody?.collisionBitMask = 0
        deadFishBullet.zPosition = 6
        deadFishBullet.xScale = 0.5
        deadFishBullet.yScale = 0.5
        addChild(deadFishBullet)
        
        let moveVector = CGVector(dx: 0, dy: -3000)
        let deadFishBulletMoveAction = SKAction.move(by: moveVector, duration: moveDuration)
        let deadFishBulletRepeat = SKAction.repeatForever(deadFishBulletMoveAction)
        deadFishBullet.run(deadFishBulletRepeat)
        
        self.deadFishAnimation = SKAction.animate(withPrefix: "DeadFish_000",
                                                  start: 15,
                                                  end: 45,
                                                  timePerFrame: 0.02)
        
        deadFishBullet.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi/4.0, duration: 0.25)))
        
        if !isNodeVisible(deadFishBullet, positionY: deadFishBullet.position.y) {
            deadFishBullet.removeFromParent()
        }
    }
    
    private func playLightningAnimation(startFrame: Int = 1, timePerFrame: TimeInterval = 0.01) -> SKAction {
        return SKAction.animate(withPrefix: "Lightning_00",
                                start: startFrame,
                                end: 201,
                                timePerFrame: timePerFrame)
    }
    
    func sceneCropAmount() -> CGFloat {
        guard let view = self.view else {
            return 0
        }
        let scale = view.bounds.size.height / self.size.height
        let scaledWidth = self.size.width * scale
        let scaledOverlap = scaledWidth - view.bounds.size.width
        return scaledOverlap / scale
    }

    private func wrapPlayerAroundEdges() {
        // Wrap player around edges of screen
        var playerPosition = convert(player.position, from: fgNode)
        let leftLimit = sceneCropAmount() / 2 - player.size.width / 2
        let rightLimit = size.width - sceneCropAmount() / 2 + player.size.width / 2

        if playerPosition.x < leftLimit {
            playerPosition = convert(CGPoint(x: rightLimit, y: 0.0), to: fgNode)
            self.player.position.x = playerPosition.x
        } else if playerPosition.x > rightLimit {
            playerPosition = convert(CGPoint(x: leftLimit, y: 0.0), to: fgNode)
            self.player.position.x = playerPosition.x
        }
    }
    
    func updateCamera() {
        let cameraTarget = convert(player.position, from: fgNode)
        var targetPositionY = cameraTarget.y + 600 - (size.height * 0.10)
        let lavaPos = convert(lava.position, from: fgNode)
        targetPositionY = max(targetPositionY, lavaPos.y)
        let diff = targetPositionY - (camera?.position.y)!
        let cameraLagFactor = CGFloat(0.2)
        let lagDiff = diff * cameraLagFactor
        let newCameraPositionY = (camera?.position.y)! + lagDiff
        
        camera?.position.y = newCameraPositionY
    }
    
    func updateLava(_ dt: TimeInterval) {
        let bottomOfScreenY = camera!.position.y - (size.height / 2)
        let bottomOfScreenYFg = convert(CGPoint(x: 0, y: bottomOfScreenY), to: fgNode).y
        var lavaVelocityY = CGFloat(0)
        
        switch score {
        case 0...10:
            lavaVelocityY = CGFloat(100)
        case 11...20:
            lavaVelocityY = CGFloat(200)
        case 21...30:
            lavaVelocityY = CGFloat(300)
        case 31...40:
            lavaVelocityY = CGFloat(325)
        case 41...50:
            lavaVelocityY = CGFloat(350)
        case 51...60:
            lavaVelocityY = CGFloat(375)
        case 61...70:
            lavaVelocityY = CGFloat(400)
        case 71...80:
            lavaVelocityY = CGFloat(425)
        case 81...90:
            lavaVelocityY = CGFloat(450)
        case 91...100:
            lavaVelocityY = CGFloat(475)
        case 101...:
            lavaVelocityY = CGFloat(500)
        default:
            lavaVelocityY = CGFloat(300)
        }
        
        let lavaStep = lavaVelocityY * CGFloat(dt)
        var newLavaPositionY = lava.position.y + lavaStep
        
        newLavaPositionY = max(newLavaPositionY, (bottomOfScreenYFg - 125.0))
        lava.position.y = newLavaPositionY
    }

    func updatePowerUp(_ dt: TimeInterval) {
        powerUpTimeSinceLastShot += dt
        
        var powerUpMoveDuration = 0.0
        if powerUpTimeSinceLastShot > powerUpNextShot {
            switch score {
            case 0...14:
                powerUpNextShot = TimeInterval(CGFloat.random(min: 5, max: 10))
                powerUpMoveDuration = 5.0
            case 15...30:
                powerUpNextShot = TimeInterval(CGFloat.random(min: 3, max: 5))
                powerUpMoveDuration = 3.0
            case 31...60:
                powerUpNextShot = TimeInterval(CGFloat.random(min: 3, max: 5))
                powerUpMoveDuration = 4.0
            case 61...:
                powerUpNextShot = TimeInterval(CGFloat.random(min: 3, max: 5))
                powerUpMoveDuration = 5.0
            default:
                fatalError()
            }
            
            powerUpTimeSinceLastShot = 0
            spawnPowerUp(moveDuration: powerUpMoveDuration)
        }
    }
    
    func updateShooter(_ dt: TimeInterval) {
        deadFishTimeSinceLastShot += dt
        var deadFishMoveDuration = 0.0
        
        if deadFishTimeSinceLastShot > deadFishNextShot {
            switch score {
            case 0...10:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 10, max: 12))
                deadFishMoveDuration = 10.0
            case 11...20:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 7, max: 9))
                deadFishMoveDuration = 9.0
            case 21...30:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 4, max: 6))
                deadFishMoveDuration = 8.0
            case 31...35:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 1, max: 3))
                deadFishMoveDuration = 7.0
            case 36...40:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 1, max: 3))
                deadFishMoveDuration = 6.0
            case 41...45:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 1, max: 3))
                deadFishMoveDuration = 6.0
            case 46...50:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 1, max: 3))
                deadFishMoveDuration = 5.0
            case 51...55:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 1, max: 3))
                deadFishMoveDuration = 4.0
            case 56...60:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 1, max: 3))
                deadFishMoveDuration = 3.0
            case 61...:
                deadFishNextShot = TimeInterval(CGFloat.random(min: 1, max: 3))
                deadFishMoveDuration = 2.0
            default:
                fatalError()
            }
            
            deadFishTimeSinceLastShot = 0
            spawnShooter(moveDuration: deadFishMoveDuration)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        
        lastUpdateTimeInterval = currentTime
        
        if isPaused {
            return
        }
        
        if gameState == .playing {
            updateCamera()
//            updateLevel()
            player.update(deltaTime)
            wrapPlayerAroundEdges()
            updateLava(deltaTime)
            updateShooter(deltaTime)
            
            if score >= 15 {
                updatePowerUp(deltaTime)
            }
            if platformState == .low || platformState == .middle || platformState == .high {
                scoreLabel.text = "\(score)"
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.move(touches, with: event)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        player.jump(platformState: platformState)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNodes[touch] != nil {
                selectedNodes[touch] = nil
            }
        }
    }
    
    func startGame() {
        self.lives = 1
        player.start()
        gameState = .playing
        platformState = .high
        
        pointerHand = SKSpriteNode(imageNamed: "PointerHand")
        pointerHand.zPosition = 100
        pointerHand.position = CGPoint(x: -250, y: 450)
        pointerHand.setScale(0.5)
        camera?.addChild(pointerHand)
        let pointerMoveRight = SKAction.move(by: CGVector(dx: 500, dy: 0), duration: 0.5)
        let pointerMoveLeft = SKAction.move(by: CGVector(dx: -500, dy: 0), duration: 0.5)
        pointerHand.run(SKAction.repeatForever(SKAction.sequence([pointerMoveRight, pointerMoveLeft])))
        
        let scaleNumber = SKAction.scale(to: 6, duration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let group = SKAction.group([scaleNumber,fadeOut])
        
        let goSign = SKSpriteNode(imageNamed: "Go_00000")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            goSign.zPosition = 100
            self.camera?.addChild(goSign)
            goSign.run(group)
            self.player.superBoostPlayer()
            self.run(self.soundJump)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.pointerHand.run(fadeOut)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.pointerHand.removeFromParent()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            goSign.removeFromParent()
        })
    }
    
    func buttonAnimation(animationBase: String, start: Int, end: Int, foreverStart: Int, foreverEnd: Int, startTimePerFrame: Double, foreverTimePerFrame: Double) -> SKAction{
        let startAction = SKAction.animate(withPrefix: animationBase,
                                           start: start,
                                           end: end,
                                           timePerFrame: startTimePerFrame)
        
        let repeatAction = SKAction.animate(withPrefix: animationBase,
                                            start: foreverStart,
                                            end: foreverEnd,
                                            timePerFrame: foreverTimePerFrame)
        
        let foreverAction = SKAction.repeatForever(repeatAction)
        let sequence = SKAction.sequence([startAction, foreverAction])
        
        return sequence
    }
    
    func setupButton(pictureBase: String, pictureWidth: Int, pictureHeight: Int, buttonPositionX: Int, buttonPositionY: Int, zPosition: CGFloat) -> SKSpriteNode {
        let button = SKSpriteNode(imageNamed: pictureBase)
        button.size = CGSize(width: pictureWidth, height: pictureHeight)
        button.position = CGPoint(x: buttonPositionX, y:buttonPositionY)
        button.zPosition = zPosition
        
        return button
    }

    func subtractLife() {
        self.lives! -= 1

        self.gameOver()
    }

    func gameOver() {
        gameState = .gameOver
        physicsWorld.contactDelegate = nil
        
        player.dead()
        
        if pointerHand != nil {
            pointerHand.removeFromParent()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.gameOverAction?(self.score)
        })
    }
    
    func emitParticles(name: String, sprite: SKSpriteNode) {
        let pos = fgNode.convert(sprite.position, from: sprite.parent!)
        let particles = SKEmitterNode(fileNamed: name)!
        particles.position = pos
        particles.zPosition = 3
        fgNode.addChild(particles)
        particles.run(SKAction.removeFromParentAfterDelay(1.0))
    }
    
    func isNodeVisible(_ node: SKNode, positionY: CGFloat) -> Bool {
        if !camera!.contains(node) {
            if positionY < camera!.position.y - size.height * 2.0 {
                return false
            }
        }
        return true
    }
}
