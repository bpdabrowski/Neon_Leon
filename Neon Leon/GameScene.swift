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
    
    var lives: Int?
    
    let soundBoost = SKAction.playSoundFileNamed("boost.wav", waitForCompletion: false)
    let soundJump = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    let soundCoin = SKAction.playSoundFileNamed("coin1.wav", waitForCompletion: false)
    let mouseHit = SKAction.playSoundFileNamed("CoinCollect.mp3", waitForCompletion: false)

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

    var isInvincible: Bool {
        return player.physicsBody?.categoryBitMask == 4096
    }
    
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

    var lifeNode1: SKSpriteNode!

    var lifeNode2: SKSpriteNode!

    var gameOverAction: ((Int) -> Void)?

    // MARK: - Static Properties

    static let playerAndInvincibleContactMask: UInt32 = 4097

    override func didMove(to view: SKView) {
        self.setupGameScene()
    }

    func setupGameScene() {
        setupNodes()
        setupLevel()
        setupPlayer()

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
    
    func setupNodes() {
        let worldNode = childNode(withName: "World")!
        bgNode = worldNode.childNode(withName: "Background")!
        backgroundOverlayTemplate = bgNode.childNode(withName: "Overlay")!.copy() as? SKNode
        backgroundOverlayHeight = backgroundOverlayTemplate.calculateAccumulatedFrame().height
        fgNode = worldNode.childNode(withName: "Foreground")!
        player = fgNode.childNode(withName: "Player") as? SKSpriteNode
        
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
    
    func setupPlayer() {
        player.physicsBody = SKPhysicsBody(circleOfRadius: 60, center: CGPoint(x: 0.5, y: 0.25))
        player.physicsBody!.isDynamic = false
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player //Invincible
        player.physicsBody!.collisionBitMask = PhysicsCategory.NoSpikePlatform
        player.physicsBody!.restitution = 0
        player.physicsBody!.affectedByGravity = false //DEBUG - Turned off player gravity
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
        
        self.deadFishAnimation = self.setupAnimationWithPrefix("DeadFish_000",
                                                                   start: 15,
                                                                   end: 45,
                                                                   timePerFrame: 0.02)
        
        deadFishBullet.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi/4.0, duration: 0.25)))
        
        if !isNodeVisible(deadFishBullet, positionY: deadFishBullet.position.y) {
            deadFishBullet.removeFromParent()
        }
    }
    
    func physicsBodySettings(for physicsBody: SKPhysicsBody) -> SKPhysicsBody {
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        return physicsBody
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
            self.blueNSPlatformAnimation = self.setupAnimationWithPrefix("BluePlatformNS_000",
                                                                 start: 30,
                                                                 end: 45,
                                                                 timePerFrame: 0.02)
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
            self.yellowPlatformAnimation = self.setupAnimationWithPrefix("YellowPlatformLt_000",
                                                                       start: 00,
                                                                       end: 30,
                                                                       timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "YellowPlatformLt_0000")
            newNode.run(SKAction.repeatForever(self.yellowPlatformAnimation))
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
            self.pinkPlatformAnimation = self.setupAnimationWithPrefix("PinkPlatformLt_000",
                                                                       start: 30,
                                                                       end: 60,
                                                                       timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "PinkPlatformLt_00030")
            newNode.run(SKAction.repeatForever(self.pinkPlatformAnimation))
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
            self.bluePlatformAnimation = self.setupAnimationWithPrefix("BluePlatformLt_000",
                                                                       start: 15,
                                                                       end: 45,
                                                                       timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "BluePlatformLt_00015")
            newNode.run(SKAction.repeatForever(self.bluePlatformAnimation))
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
            self.yellowPlatformAnimation = self.setupAnimationWithPrefix("YellowPlatformLt_000",
                                                                         start: 00,
                                                                         end: 30,
                                                                         timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "YellowPlatformLt_0000")
            newNode.run(SKAction.repeatForever(self.yellowPlatformAnimation))
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
            self.pinkPlatformAnimation = self.setupAnimationWithPrefix("PinkPlatformLt_000",
                                                                       start: 30,
                                                                       end: 60,
                                                                       timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "PinkPlatformLt_00030")
            newNode.run(SKAction.repeatForever(self.pinkPlatformAnimation))
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
            self.deadPlatformAnimation = self.setupAnimationWithPrefix("DeadPlatformLt_000",
                                                                       start: 0,
                                                                       end: 30,
                                                                       timePerFrame: 0.02)
            newNode.run(SKAction.repeatForever(self.deadPlatformAnimation))
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

    private func playLightningAnimation(startFrame: Int = 1, timePerFrame: TimeInterval = 0.01) -> SKAction {

        return self.setupAnimationWithPrefix("Lightning_00",
                                             start: startFrame,
                                             end: 201,
                                             timePerFrame: timePerFrame)
    }
    
    func setupAnimationWithPrefix(_ prefix: String, start: Int, end: Int, timePerFrame: TimeInterval) -> SKAction {
        var textures = [SKTexture]()
        for i in start...end {
            textures.append(SKTexture(imageNamed: "\(prefix)\(i)"))
        }
        return SKAction.animate(with: textures, timePerFrame: timePerFrame)
    }
    
    func runPlayerAnimation(_ animation: SKAction) {
        if currentPlayerAnimation == nil || currentPlayerAnimation! != animation {
            player.removeAction(forKey: "playerAnimation")
            player.run(animation, withKey: "playerAnimation")
            currentPlayerAnimation = animation
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
        self.wrapPlayerAroundEdges()
        self.playJumpingAnimation()
        self.togglePlayerInvincibility()
    }

    private func playJumpingAnimation() {
        guard let physicsBody = self.player.physicsBody else {
            print("Unable to get a reference to the players physics body.")
            return
        }

         let playerVerticalVelocity = physicsBody.velocity.dy

        // Check player state
        // Turn this back on when you want to add player trail
        if playerVerticalVelocity < CGFloat(0.0) && self.playerState != .fall {
            self.playerState = .fall
        } else if playerVerticalVelocity > CGFloat(0.0) && self.playerState != .jump {
            self.playerState = .jump
        }

        // Animate player
        switch playerState {
        case .jump:
            if abs(playerVerticalVelocity) > 100.0 {
                self.runPlayerAnimation(playerAnimationJump)
            }
        case .fall:
            self.runPlayerAnimation(self.playerAnimationFall)
        case .idle:
            self.runPlayerAnimation(self.playerAnimationPlatform)
        case .lava:
            break
        case .dead:
            break
        }
    }

    private func togglePlayerInvincibility() {
        if self.isInvincible {
            self.invincibleTrail = self.addTrail(name: "InvincibleTrail")
            self.invincibleTrailAttached = true
        } else if self.isInvincible && self.invincibleTrailAttached {
            self.player.removeAllChildren()
            self.player.physicsBody?.categoryBitMask = PhysicsCategory.Player
            self.invincibleTrailAttached = false
        }
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
        if self.isInvincible {
            invincibleTime += dt

            if invincibleTime > 7 {
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
        self.lives = 1

        gameState = .playing
        playerState = .idle
        platformState = .high
        
        player.physicsBody!.isDynamic = true
        
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

    func subtractLife() {
        self.lives! -= 1

        self.gameOver()
    }

    func handleRecoveryPeriod() {
        self.player.physicsBody?.categoryBitMask = PhysicsCategory.Invincible
        player.run(setupAnimationWithPrefix("NLCat_Off_", start: 1, end: 5, timePerFrame: 0.15))

        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { timer in
            self.player.physicsBody?.categoryBitMask = PhysicsCategory.Player
            timer.invalidate()
        }

        self.boostPlayer()
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

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.gameOverAction?(self.score)
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
            if !self.isInvincible {
                emitParticles(name: "LightningExplode", sprite: powerUpBullet)
                player.physicsBody?.categoryBitMask = PhysicsCategory.Invincible
                run(powerUp)
                lightningOff.run(self.playLightningAnimation(timePerFrame: 0.035))
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
                    jumpPlayer()
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
                    boostPlayer()
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
                    jumpPlayer()
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
                    boostPlayer()
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
            if !self.isInvincible {
                self.subtractLife()
            }
            run(electricute)
            
        case PhysicsCategory.Lava:
            if !self.isInvincible {
                self.subtractLife()
                run(electricute)
            } else if self.isInvincible {
                superBoostPlayer()
                run(soundJump)
            }
            
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
            if let mouse = other?.node as? SKSpriteNode {
                emitParticles(name: "MouseExplode", sprite: mouse)
                run(mouseHit)
                score += 2
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
