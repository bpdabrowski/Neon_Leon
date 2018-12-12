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
import StoreKit
import Firebase
import GoogleMobileAds


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

// MARK: - Game States
enum GameStatus: Int {
    case waitingForTap = 0
    case playing = 1
    case gameOver = 2
}

enum PlayerStatus: Int {
    case idle = 0
    case jump = 1
    case fall = 2
    case lava = 3
    case dead = 4
}

enum JumpState: Int {
    case noJump = 0
    case small = 1
    case medium = 2
    case big = 3
}

enum PlatformStatus: Int {
    case none = 0
    case low = 1
    case middle = 2
    case high = 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Properties
    var bgNode: SKNode!
    var fgNode: SKNode!
    var backgroundOverlayTemplate: SKNode!
    var backgroundOverlayHeight: CGFloat!
    var player: SKSpriteNode!
    
    var startPlatform: SKSpriteNode!
    
    var level1: SKSpriteNode!
    
    var lastOverlayPosition = CGPoint.zero
    var lastOverlayHeight: CGFloat = 0.0
    var levelPositionY: CGFloat = 0.0
    
    var gameState = GameStatus.waitingForTap
    var playerState = PlayerStatus.idle
    var jumpState = JumpState.noJump
    var platformState = PlatformStatus.none
    
    let cameraNode = SKCameraNode()
    
    var lava: SKSpriteNode!
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    
    var lives = 1
    
    let soundBoost = SKAction.playSoundFileNamed("boost.wav", waitForCompletion: false)
    let soundJump = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    let soundCoin = SKAction.playSoundFileNamed("coin1.wav", waitForCompletion: false)
    let mouseHit = SKAction.playSoundFileNamed("CoinCollect.mp3", waitForCompletion: false)
    let highScoreSound = SKAction.playSoundFileNamed("New Record.mp3", waitForCompletion: false)
    let electricute = SKAction.playSoundFileNamed("GameOver.mp3", waitForCompletion: false)
    let powerUp = SKAction.playSoundFileNamed("PowerUp.wav", waitForCompletion: false)
    
    let scoreLabel = SKLabelNode(fontNamed: "NeonTubes2-Regular")
    var score = 0
    var highScore = UserDefaults().integer(forKey: "HIGHSCORE")
    
    var playerAnimationJump: SKAction!
    var playerAnimationFall: SKAction!
    var playerAnimationPlatform: SKAction!
    var currentPlayerAnimation: SKAction?
    
    var playerTrail: SKEmitterNode!
    var invincibleTrail: SKEmitterNode!
    var invincibleTrailAttached = false

    var deadFishTimeSinceLastShot: TimeInterval = 0
    var powerUpTimeSinceLastShot: TimeInterval = 0
    var invincibleTime: TimeInterval = 0
    var deadFishNextShot: TimeInterval = 1.0
    var powerUpNextShot: TimeInterval = 1.0
    
    let gameGain: CGFloat = 2.5
    
    var redAlertTime: TimeInterval = 0
    
    var touchTime: TimeInterval = 0
    
    var squashAndStetch: SKAction!
    
    var isFingerOnCat = false
    
    var selectedNodes:[UITouch:SKSpriteNode] = [:]
    
    var tapCount: Int!
    
    var breakAnimation: SKAction!
    
    var lightningAnimation: SKAction!
    
    var platformProbes: SKSpriteNode!
    
    var avPlayer: AVPlayer!
    var video: SKVideoNode!
    
    var reviewButton: Button!
    var noAdsStart: Button!
    var tutorialButton: Button!
    
    var lightningOff: SKSpriteNode!
    var lightningOff2: SKSpriteNode!
    var lightningOff3: SKSpriteNode!
    
    var bluePlatformAnimation: SKAction!
    var yellowPlatformAnimation: SKAction!
    var pinkPlatformAnimation: SKAction!
    var blueNSPlatformAnimation: SKAction!
    var yellowNSPlatformAnimation: SKAction!
    var pinkNSPlatformAnimation: SKAction!
    var deadPlatformAnimation: SKAction!
    var startPlatformAnimation: SKAction!
    var lightningTrapAnimation: SKAction!
    var deadFishAnimation: SKAction!
    var platformMoveRight: SKAction!
    var platformMoveLeft: SKAction!
    var platformMoveSequence: SKAction!
    var platformGroup: SKAction!
    
    let userDefaults = UserDefaults.standard
    
    var invincible = false //Invincible
    
    var powerUpBullet: SKSpriteNode!
    var deadFishBullet: SKSpriteNode!
    
    var onPlatform = false
    
    var animationLoopUp: SKAction!
    var animationLoopDown: SKAction!
    var wait1: SKAction!
    var wait2: SKAction!
    var wait3: SKAction!
    var wait5: SKAction!
    
    var pointerHand: SKSpriteNode! = nil
    
    let notification = UINotificationFeedbackGenerator()
    
    var didLand = false
    
    let gvc = GameViewController()
    
    override func didMove(to view: SKView) {
        view.showsPhysics = false
        
        self.setupNodes()
        self.setupLevel()
        self.setupPlayer()
        
        physicsWorld.contactDelegate = self
        
        camera?.position = CGPoint(x: size.width/2, y: size.height/2)
        
        playerAnimationJump = setupAnimationWithPrefix("NLCat_Jump_", start: 1, end: 4, timePerFrame: 0.025)
        playerAnimationFall = setupAnimationWithPrefix("NLCat_Fall_", start: 1, end: 6, timePerFrame: 0.025)
        playerAnimationPlatform = setupAnimationWithPrefix("NLCat_Platform_", start: 1, end: 4, timePerFrame: 0.025)

        lightningOff = SKSpriteNode(imageNamed: "Lightning_00000")
        lightningOff.size = CGSize(width: 375, height: 390)
        lightningOff.zPosition = 4
        lightningOff.position = CGPoint(x: -450, y: 900)
        camera?.addChild(lightningOff)
        

        
        animationLoopDown = setupAnimationWithPrefix("Lightning_00",
                                                     start: 1,
                                                     end: 201,
                                                     timePerFrame: 0.035)
        
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 200
        scoreLabel.zPosition = 8
        scoreLabel.position = CGPoint(x: 0, y: 825)
        camera?.addChild(scoreLabel)

        startGame()
    }
    
    func setupNodes() {
        let worldNode = childNode(withName: "World")!
        bgNode = worldNode.childNode(withName: "Background")!
        backgroundOverlayTemplate = bgNode.childNode(withName: "Overlay")!.copy() as? SKNode
        backgroundOverlayHeight = backgroundOverlayTemplate.calculateAccumulatedFrame().height
        fgNode = worldNode.childNode(withName: "Foreground")!
        player = fgNode.childNode(withName: "Player") as? SKSpriteNode
        
        startPlatform = loadForegroundOverlayTemplate("StartPlatform")
        level1 = loadForegroundOverlayTemplate("Level1")
        
        addChild(cameraNode)
        camera = cameraNode
        
        setupLava()
        setupBackground("Background.sks")
    }
    
    func setupLevel() {
        // Place initial platform
        let initialPlatform = startPlatform.copy() as! SKSpriteNode
        startPlatformAnimation = setupAnimationWithPrefix("StartPlatform_000",
                                                                    start: 1,
                                                                    end: 30,
                                                                    timePerFrame: 0.05)
        
        initialPlatform.size = CGSize(width: 1536, height: 300)
        initialPlatform.zPosition = 1
        
        var overlayPosition = CGPoint(x: 0, y: 0)
        
        // Made platform height up to match the anchor point of the player.
        // Changed ((player.size.height * 0.5) to ((player.size.height * 0.316)
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
    
    func setupPlayer() {
        player.physicsBody = SKPhysicsBody(circleOfRadius: 60, center: CGPoint(x: 0.5, y: 0.25))
        player.physicsBody!.isDynamic = false
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player //Invincible
        player.physicsBody!.collisionBitMask = PhysicsCategory.NoSpikePlatform
        player.physicsBody!.restitution = 0
        player.physicsBody!.affectedByGravity = false
        player.physicsBody?.linearDamping = 1.0
        player.physicsBody?.friction = 1.0
    }
    
    func setupLava() {
        lava = fgNode.childNode(withName: "Lava") as? SKSpriteNode
    }
    
    func setupBackground(_ fileName: String) {
        let emitter = SKEmitterNode(fileNamed: fileName)!
        emitter.particlePositionRange = CGVector(dx: size.width * 1.125, dy: size.height * 2)
        emitter.advanceSimulationTime(3.0)
        camera?.addChild(emitter)
    }
    
    func spawnPowerUp(moveDuration: TimeInterval) {
        powerUpBullet = SKSpriteNode(imageNamed: "Lightning_0028")
    
        powerUpBullet.position = CGPoint(
            x: random(min: 300, max: 500),
            y: self.size.height + camera!.position.y - 768
        )
    
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
        
        self.deadFishAnimation = self.setupAnimationWithPrefix("DeadFish_000",
                                                                   start: 15,
                                                                   end: 45,
                                                                   timePerFrame: 0.02)
        
        deadFishBullet.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi/4.0, duration: 0.25)))
        
        if !isNodeVisible(deadFishBullet, positionY: deadFishBullet.position.y) {
            deadFishBullet.removeFromParent()
        }
    }
    
    private func mouseOverlay(overlay: SKSpriteNode) {
        overlay.enumerateChildNodes(withName: "Mouse") { (node, stop) in
            let newNode = SKSpriteNode(imageNamed: "Mouse_00000")
            newNode.size = CGSize(width: 125, height: 107)
            newNode.zPosition = 1
            newNode.position = CGPoint(x: CGFloat.random(min: -425, max: 425), y: CGFloat.random(min: -1024, max: 980))
            
            newNode.physicsBody = SKPhysicsBody(circleOfRadius: newNode.size.width / 4)
            self.setupNodePhysics(nodePhysics: newNode.physicsBody!, categoryMask: PhysicsCategory.Mouse, contactMask: PhysicsCategory.Player)
            
            let moveUp = SKAction.move(by: CGVector(dx: 0, dy: 20), duration: 0.5)
            let moveDown = SKAction.move(by: CGVector(dx: 0, dy: -20), duration: 0.5)
            newNode.run(SKAction.repeatForever(SKAction.sequence([moveUp, moveDown])))

            overlay.addChild(newNode)
            node.removeFromParent()
        }
    }
    
    private func setupNodePhysics(nodePhysics: SKPhysicsBody, categoryMask: UInt32, contactMask: UInt32) {
        nodePhysics.isDynamic = false
        nodePhysics.affectedByGravity = false
        nodePhysics.allowsRotation = false
        
        nodePhysics.categoryBitMask = categoryMask
        nodePhysics.contactTestBitMask = contactMask
    }
    
    private func setupPlatform(imageNamed image: String) -> SKSpriteNode {
        let newNode = SKSpriteNode(imageNamed: image)
        newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 117, height: 90))
        newNode.size = CGSize(width: 350, height: 216)
        newNode.zPosition = 1
        newNode.position = CGPoint(x: CGFloat.random(min: -425, max: 425), y: CGFloat.random(min: -1024, max: 980))
        
        return newNode
    }
    
    func addAnimationToOverlay(overlay: SKSpriteNode) {
        overlay.enumerateChildNodes(withName: "PlatformLow") { (node, stop) in
            let newNode = self.setupPlatform(imageNamed: "BluePlatformLt_00015")
            
            self.setupNodePhysics(nodePhysics: newNode.physicsBody!,
                                  categoryMask: PhysicsCategory.BackupLow,
                                  contactMask: PhysicsCategory.Player | PhysicsCategory.Invincible)
            
            self.bluePlatformAnimation = self.setupAnimationWithPrefix("BluePlatformLt_000",
                                                                       start: 15,
                                                                       end: 45,
                                                                       timePerFrame: 0.02)
            newNode.run(SKAction.repeatForever(self.bluePlatformAnimation))
            
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "PlatformMid") { (node, stop) in
            let newNode = self.setupPlatform(imageNamed: "YellowPlatformLt_0000")
            
            self.setupNodePhysics(nodePhysics: newNode.physicsBody!,
                                  categoryMask: PhysicsCategory.BackupMiddle,
                                  contactMask: PhysicsCategory.Player | PhysicsCategory.Invincible)
            
            self.yellowPlatformAnimation = self.setupAnimationWithPrefix("YellowPlatformLt_000",
                                                                         start: 00,
                                                                         end: 30,
                                                                         timePerFrame: 0.02)
            newNode.run(SKAction.repeatForever(self.yellowPlatformAnimation))
            
            overlay.addChild(newNode)
            node.removeFromParent()
        }
        
        overlay.enumerateChildNodes(withName: "PlatformHigh") { (node, stop) in
            let newNode = self.setupPlatform(imageNamed: "PinkPlatformLt_00030")
            
            self.setupNodePhysics(nodePhysics: newNode.physicsBody!,
                                  categoryMask: PhysicsCategory.BackupHigh,
                                  contactMask: PhysicsCategory.Player | PhysicsCategory.Invincible)
            
            self.pinkPlatformAnimation = self.setupAnimationWithPrefix("PinkPlatformLt_000",
                                                                       start: 30,
                                                                       end: 60,
                                                                       timePerFrame: 0.02)
            newNode.run(SKAction.repeatForever(self.pinkPlatformAnimation))
            
            overlay.addChild(newNode)
            print("Platform position: \(newNode.position)")
            
            node.removeFromParent()
        }
        
        self.mouseOverlay(overlay: overlay)
    }
    
    func setupAnimationWithPrefix(_ prefix: String, start: Int, end: Int, timePerFrame: TimeInterval) -> SKAction {
        var textures = [SKTexture]()
        for i in start...end {
            textures.append(SKTexture(imageNamed: "\(prefix)\(i)"))
        }
        return SKAction.animate(with: textures, timePerFrame: timePerFrame)
    }
    
    func runPlayerAnimation(_ animation: SKAction) {
        if self.currentPlayerAnimation == nil || self.currentPlayerAnimation! != animation {
            self.player.removeAction(forKey: "playerAnimation")
            self.player.run(animation, withKey: "playerAnimation")
            self.currentPlayerAnimation = animation
        }
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
    
    func updatePlayer() {
        // Wrap player around edges of screen
        var playerPosition = convert(player.position, from: self.fgNode)
        let leftLimit = sceneCropAmount()/2 - player.size.width/2
        let rightLimit = size.width - sceneCropAmount()/2 + player.size.width/2
        if playerPosition.x < leftLimit {
            playerPosition = convert(CGPoint(x: rightLimit, y: 0.0), to: self.fgNode)
            self.player.position.x = playerPosition.x
        }
        else if playerPosition.x > rightLimit {
            playerPosition = convert(CGPoint(x: leftLimit, y: 0.0), to: self.fgNode)
            self.player.position.x = playerPosition.x
        }
        
        // Check player state
        // Turn this back on when you want to add player trail
        if self.player.physicsBody!.velocity.dy < CGFloat(0.0) && self.playerState != .fall {
            self.playerState = .fall
        } else if self.player.physicsBody!.velocity.dy > CGFloat(0.0) && self.playerState != .jump {
            self.playerState = .jump
        }
        
        // Animate player
        switch playerState {
        case .jump:
            if abs(player.physicsBody!.velocity.dy) > 100.0 {
                runPlayerAnimation(playerAnimationJump)
            }
        case .fall:
            runPlayerAnimation(playerAnimationFall)
        case .idle:
            runPlayerAnimation(playerAnimationPlatform)
        case .lava:
            break
        case .dead:
            break
        }
        
        if self.invincible == true {
            self.invincibleTrail = addTrail(name: "InvincibleTrail")
            self.invincibleTrailAttached = true
        } else if invincible == false && invincibleTrailAttached == true {
            self.player.removeAllChildren()
            self.player.physicsBody?.categoryBitMask = PhysicsCategory.Player
            self.invincibleTrailAttached = false
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
        
        switch self.score {
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
        self.lava.position.y = newLavaPositionY
    }
    
    func updateCollisionLava() {
        if self.player.position.y < self.lava.position.y - 500 {
            if playerState != .lava {
                playerState = .lava
                playerTrail.particleBirthRate = 0
            }
            self.boostPlayer()
            lives -= 1
            if lives <= 0 {
                gameOver()
            }
        }
    }
    
    func updatePowerUp(_ dt: TimeInterval) {
        self.powerUpTimeSinceLastShot += dt
        
        var powerUpMoveDuration = 0.0
        if self.powerUpTimeSinceLastShot > powerUpNextShot {
            switch self.score {
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
            
            self.powerUpTimeSinceLastShot = 0
            self.spawnPowerUp(moveDuration: powerUpMoveDuration)
        }
    }
    
    func updateShooter(_ dt: TimeInterval) {
        self.deadFishTimeSinceLastShot += dt
        var deadFishMoveDuration = 0.0
        
        if self.deadFishTimeSinceLastShot > deadFishNextShot {
            switch self.score {
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
            
            self.deadFishTimeSinceLastShot = 0
            self.spawnShooter(moveDuration: deadFishMoveDuration)
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
            updateLevel()
            updatePlayer()
            updateLava(deltaTime)
            updateShooter(deltaTime)
            
            if score >= 15 {
                updatePowerUp(deltaTime)
            }
            endInvincible(deltaTime)
            
            if platformState == .low || platformState == .middle || platformState == .high {
                scoreLabel.text = "\(score)"
            }
            
            if playerState != .idle {
                player.physicsBody?.affectedByGravity = true
            }
        }
    }
    
    func endInvincible(_ dt: TimeInterval) {
        if invincible == true {
            invincibleTime += dt
            if invincibleTime > 7 { //Invincible
                invincible = false
                player.physicsBody?.categoryBitMask = PhysicsCategory.Player
                invincibleTime = 0
            }
        }
    }
    
    func setPlayerVelocity(_ amount: CGFloat) {
        player.physicsBody!.velocity.dy = max(player.physicsBody!.velocity.dy, amount * gameGain)
    }
    
    func jumpPlayer() {
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 550))
    }
    
    func boostPlayer() {
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 850))
    }
    
    func superBoostPlayer() {
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 1100))
    }
    
    // MARK: - Overlay nodes
    
    func loadForegroundOverlayTemplate(_ fileName: String) -> SKSpriteNode {
        let overlayScene = SKScene(fileNamed: fileName)!
        let overlayTemplate = overlayScene.childNode(withName: "Overlay")
        return overlayTemplate as! SKSpriteNode
    }
    
    func loadCoin(_ fileName: String) -> SKSpriteNode {
        let coinScene = SKScene(fileNamed: fileName)!
        let coinTemplate = coinScene.childNode(withName: "Coin")
        return coinTemplate as! SKSpriteNode
    }
    
    func loadPlatform(_ fileName: String) -> SKSpriteNode {
        let platformScene = SKScene(fileNamed: fileName)!
        let platformTemplate = platformScene.childNode(withName: "Platform")
        return platformTemplate as! SKSpriteNode
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
                default:
                    overlaySprite = level1
                }
                
                createForegroundOverlay(overlaySprite, flipX: flipH)
            }
        }
    }

    func createBackgroundOverlay() {
        let backgroundOverlay = backgroundOverlayTemplate.copy() as! SKNode
        backgroundOverlay.position = CGPoint(x: 0.0, y: levelPositionY)
        bgNode.addChild(backgroundOverlay)
        levelPositionY += backgroundOverlayHeight
    }
    
    // MARK: - Events
    
    func showNewScene() {
        let newScene = GameScene(fileNamed: "GameScene")
        newScene!.scaleMode = .aspectFill
        let fade = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(newScene!, transition: fade)
    }
    
    func showMainMenu() {
        let newScene = GameScene(fileNamed: "MainMenu")
        newScene!.scaleMode = .aspectFill
        let fade = SKTransition.fade(withDuration: 0.5)
        self.view?.presentScene(newScene!, transition: fade)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if playerState != .dead {
            if playerState != .idle {
                let touch = touches.first
                let touchLocation = touch!.location(in: fgNode)
                let previousLocation = touch!.previousLocation(in: fgNode)
                let touchDifference = touchLocation.x - previousLocation.x
                let catX = player.position.x + ((touchDifference) * 1.25)
                player.position = CGPoint(x: catX, y: player.position.y)
                if touchDifference <= 0 {
                    player.xScale = -abs(player.xScale)
                } else {
                    player.xScale = abs(player.xScale)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if selectedNodes[touch] != nil {
                selectedNodes[touch] = nil
            }
        }
        
        isFingerOnCat = false
    }
    
    func startGame() {
        gameState = .playing
        playerState = .idle
        platformState = .high
        
        player.physicsBody!.isDynamic = true
        
        pointerHand = SKSpriteNode(imageNamed: "PointerHand")
        pointerHand.zPosition = 100
        pointerHand.position = CGPoint(x: -250, y: 450 /*-650*/)
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
            self.superBoostPlayer()
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
        let startAction = setupAnimationWithPrefix(animationBase,
                                                   start: start,
                                                   end: end,
                                                   timePerFrame: startTimePerFrame)
        
        let repeatAction = setupAnimationWithPrefix(animationBase,
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
    
    func gameOver() {
        gameState = .gameOver
        playerState = .dead
        
        physicsWorld.contactDelegate = nil
        player.physicsBody?.isDynamic = false
        
        let playerAnimationOff = setupAnimationWithPrefix("NLCat_Off_", start: 1, end: 7, timePerFrame: 0.05)
        player.run(playerAnimationOff)
        
         let wait = SKAction.wait(forDuration: 0.3)
         let moveUp = SKAction.moveBy(x: 0.0, y: 200, duration: 0.2)
         moveUp.timingMode = .easeOut
         let moveDown = SKAction.moveBy(x: 0.0,
         y: -(size.height * 1.5),
         duration: 1.0)
         moveDown.timingMode = .easeIn
         player.run(SKAction.sequence([wait, moveUp, moveDown]))
        
        if pointerHand != nil {
            pointerHand.removeFromParent()
        }
        
        if score > userDefaults.integer(forKey: "HIGHSCORE") {
            saveHighScore()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            let restartButton = self.setupButton(pictureBase: "RestartButton_00040", pictureWidth: 335, pictureHeight: 357, buttonPositionX: -600, buttonPositionY: -600, zPosition: 8)
            
            let restartButtonAnimation = self.buttonAnimation(animationBase: "RestartButton_000", start: 40, end: 45, foreverStart: 46, foreverEnd: 60, startTimePerFrame: 0.035, foreverTimePerFrame: 0.035)
            
            let restartButtonTransparent = Button(defaultButtonImage: "NoAds_00010", activeButtonImage: "RestartButton_00030", buttonAction: self.showNewScene)
            restartButtonTransparent.position = CGPoint(x: -385, y: -600)
            restartButtonTransparent.alpha = 0.01
            restartButtonTransparent.zPosition = 10
            
            let restartMove = SKAction.moveBy(x: 215, y: 0, duration: 0.5)
            
            self.camera?.addChild(restartButtonTransparent)
            self.camera?.addChild(restartButton)
            restartButton.run(SKAction.sequence([restartMove,restartButtonAnimation]))
            
            
            let gameOverLabel = self.setupButton(pictureBase: "GameOver_00000", pictureWidth: 1100, pictureHeight: 600, buttonPositionX: -50, buttonPositionY: 1100, zPosition: 8)
            
            let gameOverAnimation = self.buttonAnimation(animationBase: "GameOver_000", start: 1, end: 19, foreverStart: 20, foreverEnd: 35, startTimePerFrame: 0.035, foreverTimePerFrame: 0.035)
            
            let gameOverMove = SKAction.moveBy(x: 0, y: -600, duration: 0.5)
            
            self.camera?.addChild(gameOverLabel)
            gameOverLabel.run(SKAction.sequence([gameOverMove,gameOverAnimation]))
            
            let noAdsButton = self.setupButton(pictureBase: "NoAds_00000", pictureWidth: 335, pictureHeight: 357, buttonPositionX: 600, buttonPositionY: -600, zPosition: 8)
            
            let noAdsButtonAnimation = self.buttonAnimation(animationBase: "NoAds_000", start: 1, end: 2, foreverStart: 3, foreverEnd: 43, startTimePerFrame: 0.05, foreverTimePerFrame: 0.05)
            
            let noAdsButtonTransparent = Button(defaultButtonImage: "NoAds_00000", activeButtonImage: "NoAds_00000", buttonAction: self.gvc.removeAds)
            
            noAdsButtonTransparent.position = CGPoint(x: 385, y: -600)
            noAdsButtonTransparent.alpha = 0.01
            noAdsButtonTransparent.zPosition = 10
            
            let noAdsMove = SKAction.moveBy(x: -215, y: 0, duration: 0.5)
            
            self.camera?.addChild(noAdsButtonTransparent)
            self.camera?.addChild(noAdsButton)
            noAdsButton.run(SKAction.sequence([noAdsMove,noAdsButtonAnimation]))
            
            let mainMenuButton = self.setupButton(pictureBase: "HomeButton_00030", pictureWidth: 200, pictureHeight: 200, buttonPositionX: 0, buttonPositionY: -505, zPosition: 8)
            
            let mainMenuButtonAnimation = self.buttonAnimation(animationBase: "HomeButton_000", start: 30, end: 31, foreverStart: 32, foreverEnd: 60, startTimePerFrame: 0.035, foreverTimePerFrame: 0.035)
            
            let mainMenuButtonTransparent = Button(defaultButtonImage: "SmallButtonCircle", activeButtonImage: "SmallButtonCircle", buttonAction: self.showMainMenu)
            
            mainMenuButtonTransparent.position = CGPoint(x: 0, y: -505)
            mainMenuButtonTransparent.alpha = 0.01
            mainMenuButtonTransparent.zPosition = 10
            
            let mainMenuMove = SKAction.moveBy(x: 0, y: 0, duration: 0.5)
            
            self.camera?.addChild(mainMenuButtonTransparent)
            self.camera?.addChild(mainMenuButton)
            mainMenuButton.run(SKAction.sequence([mainMenuMove,mainMenuButtonAnimation]))
            
            let restoreIAPButton = self.setupButton(pictureBase: "RestoreIAP_00000", pictureWidth: 200, pictureHeight: 200, buttonPositionX: 0, buttonPositionY: -705, zPosition: 8)
            
            let restoreIAPButtonAnimation = self.buttonAnimation(animationBase: "RestoreIAP_000", start: 1, end: 2, foreverStart: 3, foreverEnd: 15, startTimePerFrame: 0.035, foreverTimePerFrame: 0.035)
            
            let restoreIAPButtonTransparent = Button(defaultButtonImage: "SmallButtonCircle", activeButtonImage: "SmallButtonCircle", buttonAction: self.gvc.restorePurchasesWithAlert)
            
            restoreIAPButtonTransparent.position = CGPoint(x: 0, y: -705)
            restoreIAPButtonTransparent.alpha = 0.01
            restoreIAPButtonTransparent.zPosition = 10
            
            self.camera?.addChild(restoreIAPButtonTransparent)
            self.camera?.addChild(restoreIAPButton)
            restoreIAPButton.run(SKAction.sequence([mainMenuMove,restoreIAPButtonAnimation]))
            
            let dimmerSprite = SKSpriteNode(imageNamed: "Dimmer")
            dimmerSprite.position = self.camera!.position
            dimmerSprite.zPosition = 7
            self.addChild(dimmerSprite)
            
            if let alarm = self.childNode(withName: "alarm") {
                alarm.removeFromParent()
            }
            
            let highScoreLabel = SKSpriteNode(imageNamed: "BestLabel_00000")
            highScoreLabel.position = CGPoint(x: -200, y: -82)
            highScoreLabel.zPosition = 8
            self.camera?.addChild(highScoreLabel)
            
            let highScoreLabelAnimation = self.buttonAnimation(animationBase: "BestLabel_000", start: 1, end: 30, foreverStart: 31, foreverEnd: 60, startTimePerFrame: 0.06, foreverTimePerFrame: 0.06)
            
            highScoreLabel.run(highScoreLabelAnimation)
            
            let highScoreNumber = SKLabelNode(fontNamed: "NeonTubes2-Regular")
            highScoreNumber.fontSize = 200
            highScoreNumber.position = CGPoint(x: 300, y: -125)
            highScoreNumber.zPosition = 8
            highScoreNumber.text = "\(UserDefaults().integer(forKey: "HIGHSCORE"))"
            self.camera?.addChild(highScoreNumber)
            
            if let viewController = self.view?.window?.rootViewController {
                if SwiftyAd.shared.isInterstitialReady {
                    SwiftyAd.shared.showInterstitial(from: viewController, withInterval: 5)
                }
            }
        })
    }
    
    func playerPlatformSettings() {
        // When this is turned off, the player doesn't jump to the correct height
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.affectedByGravity = false
        playerState = .idle
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.powerUp:
            if invincible == false {
                invincible = true
                emitParticles(name: "LightningExplode", sprite: powerUpBullet)
                player.physicsBody?.categoryBitMask = PhysicsCategory.Invincible
                run(powerUp)
                lightningOff.run(animationLoopDown)
                notification.notificationOccurred(.warning)
                powerUpBullet.removeFromParent()
            }
            
        case PhysicsCategory.PlatformLow:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .low
                    emitParticles(name: "OneArrow", sprite: platform)
                    onPlatform = true
                    superBoostPlayer()
                    run(soundJump)
                    platform.removeFromParent()
                    score += 1
                }
            }
            
        case PhysicsCategory.PlatformMiddle:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .middle
                    emitParticles(name: "TwoArrows", sprite: platform)
                    run(soundJump)
                    superBoostPlayer()
                    platform.removeFromParent()
                    score += 1
                }
            }
            
        case PhysicsCategory.PlatformHigh:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .high
                    emitParticles(name: "ThreeArrows", sprite: platform)
                    superBoostPlayer()
                    run(soundJump)
                    platform.removeFromParent()
                    score += 1
                }
            }
            
        case PhysicsCategory.BackupLow:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .low
                    emitParticles(name: "OneArrow", sprite: platform)
                    onPlatform = true
                    superBoostPlayer()
                    run(soundJump)
                }
            }
            
        case PhysicsCategory.BackupMiddle:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .middle
                    emitParticles(name: "TwoArrows", sprite: platform)
                    run(soundJump)
                    superBoostPlayer()
                }
            }
            
        case PhysicsCategory.BackupHigh:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .high
                    emitParticles(name: "ThreeArrows", sprite: platform)
                    superBoostPlayer()
                    run(soundJump)
                }
            }
            
        case PhysicsCategory.Spikes:
                    notification.notificationOccurred(.error)
                    gameOver()
                    run(electricute)
            
        case PhysicsCategory.Lava:
            if invincible == false {
                gameOver()
                run(electricute)
            } else if invincible == true {
                superBoostPlayer()
                run(soundJump)
            }
            
        default:
            break
        }
    }
    
    func saveHighScore() {
        UserDefaults().set(score, forKey: "HIGHSCORE")
        
        let newHighScoreBanner = SKLabelNode(fontNamed: "NeonTubes2-Regular")
        newHighScoreBanner.fontSize = 100
        newHighScoreBanner.position = CGPoint(x: -1100, y: 725)
        newHighScoreBanner.zPosition = 8
        newHighScoreBanner.text = "NEW HIGH SCORE!"
        
        if gameState == .gameOver {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.run(self.highScoreSound)
                self.camera?.addChild(newHighScoreBanner)
                newHighScoreBanner.run(SKAction.move(by: CGVector(dx: 3000, dy: 0), duration: 3))
                
                // Requests user to make a review after losing, doesn't happen everytime. It is controlled by Apple.
                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                }
            })
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.Mouse:
            if let mouse = other.node as? SKSpriteNode {
                emitParticles(name: "MouseExplode", sprite: mouse)
                run(mouseHit)
                score += 3
                mouse.removeFromParent()
            }
            
        default:
            break
            }
        }
    
    func addTrail(name: String) -> SKEmitterNode {
        let trail = SKEmitterNode(fileNamed: name)!
        trail.zPosition = -1
        trail.position = CGPoint(x: -100, y: 0)
        trail.targetNode = fgNode
        player.addChild(trail)
        return trail
    }
    
    func removeTrail(trail: SKEmitterNode) {
        trail.numParticlesToEmit = 1
        trail.run(SKAction.removeFromParentAfterDelay(1.0))
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
    
    func platformAction(_ sprite: SKSpriteNode, breakable: Bool) {
        let amount = CGPoint(x: 0, y: -75.0)
        let action = SKAction.screenShakeWithNode(sprite, amount: amount, oscillations: 10, duration: 2.0)
        sprite.run(action)
    }
    
    func movePlatform(_ sprite: SKSpriteNode, breakable: Bool) {
        let moveVector = CGVector.init(dx: 200, dy: 0)
        let action = SKAction.move(by: moveVector, duration: 4)
        sprite.run(action)
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}
