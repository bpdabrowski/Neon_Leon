//  GameScene.swift
//  DropCharge
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2017 Broski Studios. All rights reserved.
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
    static let CatNip: UInt32               = 0b10000 // 16
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
    case waitingForBomb = 1
    case playing = 2
    case gameOver = 3
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
    
    var pinkPlatform: SKSpriteNode!
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
    
    var lastOverlayPosition = CGPoint.zero
    var lastOverlayHeight: CGFloat = 0.0
    var levelPositionY: CGFloat = 0.0
    
    var gameState = GameStatus.waitingForTap
    var playerState = PlayerStatus.idle
    var jumpState = JumpState.noJump
    var platformState = PlatformStatus.none

    //var xAcceleration = CGFloat(0)
    
    let cameraNode = SKCameraNode()
    
    var lava: SKSpriteNode!
    
    var lastUpdateTimeInterval: TimeInterval = 0
    var deltaTime: TimeInterval = 0
    
    var lives = 1
    
    let soundBoost = SKAction.playSoundFileNamed("boost.wav", waitForCompletion: false)
    let soundJump = SKAction.playSoundFileNamed("jump.wav", waitForCompletion: false)
    let soundCoin = SKAction.playSoundFileNamed("coin1.wav", waitForCompletion: false)
    let catNipRoar = SKAction.playSoundFileNamed("CatNipRoar.mp3", waitForCompletion: false)
    let mouseHit = SKAction.playSoundFileNamed("CoinCollect.mp3", waitForCompletion: false)
    let highScoreSound = SKAction.playSoundFileNamed("New Record.mp3", waitForCompletion: false)
    let electricute = SKAction.playSoundFileNamed("GameOver.mp3", waitForCompletion: false)
    let powerUp = SKAction.playSoundFileNamed("PowerUp.wav", waitForCompletion: false)
    
    let scoreLabel = SKLabelNode(fontNamed: "NeonTubes2-Regular")
    var score = 0
    var highScore = UserDefaults().integer(forKey: "HIGHSCORE")
    //let jumpLabel = SKLabelNode(fontNamed: "NeonTubes2-Regular")
    
    
    /*let soundExplosions = [
        SKAction.playSoundFileNamed("explosion1.wav", waitForCompletion: false),
        SKAction.playSoundFileNamed("explosion2.wav", waitForCompletion: false),
        SKAction.playSoundFileNamed("explosion3.wav", waitForCompletion: false),
        SKAction.playSoundFileNamed("explosion4.wav", waitForCompletion: false)
    ]*/
    
    var playerAnimationJump: SKAction!
    var playerAnimationFall: SKAction!
    var playerAnimationPlatform: SKAction!
    var currentPlayerAnimation: SKAction?
    //var playerAnimationSteerLeft: SKAction!
    //var playerAnimationSteerRight: SKAction!
    
    var playerTrail: SKEmitterNode!
    var poisonTrail: SKEmitterNode!
    var invincibleTrail: SKEmitterNode!
    var invincibleTrailAttached = false
    
    var timeSinceLastExplosion: TimeInterval = 0
    var timeForNextExplosion: TimeInterval = 1.0
    
    var deadFishTimeSinceLastShot: TimeInterval = 0
    var catNipTimeSinceLastShot: TimeInterval = 0
    var invincibleTime: TimeInterval = 0
    var deadFishNextShot: TimeInterval = 1.0
    var catNipNextShot: TimeInterval = 1.0
    
    let gameGain: CGFloat = 2.5
    
    var redAlertTime: TimeInterval = 0
    
    var touchTime: TimeInterval = 0
    
    var squashAndStetch: SKAction!
    
    var isFingerOnCat = false
    
    var selectedNodes:[UITouch:SKSpriteNode] = [:]
    
    var tapCount: Int!
    
    var coinAnimationNormal: SKAction!
    var coinAnimationSpecial: SKAction!
    
    var breakAnimation: SKAction!
    var poisonBeakerMove: SKAction!
    var poisonBeakerSequence: SKAction!
    
    var lightningAnimation: SKAction!
    
    var platformProbes: SKSpriteNode!
    
    //let animationView = LOTAnimationView(name: "TestNL")
    
    var avPlayer: AVPlayer!
    var video: SKVideoNode!
    
    //var powerBar: SKSpriteNode!
    
    var playButton: Button!
    var reviewButton: Button!
    var noAdsStart: Button!
    var tutorialButton: Button!
    
    var lightningOff: SKSpriteNode!
    var lightningOff2: SKSpriteNode!
    var lightningOff3: SKSpriteNode!
    
    var bluePlatformAnimation: SKAction!
    var yellowPlatformAnimation: SKAction!
    var pinkPlatformAnimation: SKAction!
    var deadPlatformAnimation: SKAction!
    var startPlatformAnimation: SKAction!
    var lightningTrapAnimation: SKAction!
    var deadFishAnimation: SKAction!
    
    let userDefaults = UserDefaults.standard
    
    var invincible = false //Invincible
    
    var catNipBullet: SKSpriteNode!
    var deadFishBullet: SKSpriteNode!
    
    var onPlatform = false
    
    var animationLoopUp: SKAction!
    var animationLoopDown: SKAction!
    var wait1: SKAction!
    var wait2: SKAction!
    var wait3: SKAction!
    var wait5: SKAction!
    
    let mainMenu = MainMenu()
    
    var pointerHand: SKSpriteNode! = nil
    
    let notification = UINotificationFeedbackGenerator()
    
    var didLand = false
    
    /*required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObservers()
    }*/
    
    //3
    override func didMove(to view: SKView) {
        view.showsPhysics = true
        
        addObservers()
        
        /*animationView.frame = CGRect(x: 0, y: 0, width: 1018, height: 337)
        animationView.loopAnimation = false
        
        view.addSubview(animationView)
        animationView.layer.zPosition = 999
        animationView.play()*/
        coinAnimationNormal = setupAnimationWithPrefix("powerup05_", start: 1, end: 6, timePerFrame: 0.1)
        coinAnimationSpecial = setupAnimationWithPrefix("powerup01_", start: 1, end: 6, timePerFrame: 0.1)
        //breakAnimation = setupAnimationWithPrefix("PinkPlatformLt_", start: 1, end: 2, timePerFrame: 0.1)
        poisonBeakerMove = SKAction.moveBy(x: -200, y: 0, duration: 0.5)
        poisonBeakerSequence = SKAction.sequence([poisonBeakerMove, poisonBeakerMove.reversed()])

        
        setupNodes()
        setupLevel()
        setupPlayer()
        
        //findChild()
        
        
        /*let scale = SKAction.scale(to: 1.0, duration: 0.5)
        fgNode.childNode(withName: "Ready")!.run(scale)*/
        
        physicsWorld.contactDelegate = self
        
        camera?.position = CGPoint(x: size.width/2, y: size.height/2)
        
        playBackgroundMusic(name: "Spacebased2.mp3")
        
        //playBackgroundMusic(name: "SpaceGame.caf")
        
        playerAnimationJump = setupAnimationWithPrefix("NLCat_Jump_", start: 1, end: 4, timePerFrame: 0.025)
        playerAnimationFall = setupAnimationWithPrefix("NLCat_Fall_", start: 1, end: 6, timePerFrame: 0.025)
        playerAnimationPlatform = setupAnimationWithPrefix("NLCat_Platform_", start: 1, end: 4, timePerFrame: 0.025)
        //playerAnimationSteerLeft = setupAnimationWithPrefix("player01_steerleft_", start: 1, end: 2, timePerFrame: 0.1)
        //playerAnimationSteerRight = setupAnimationWithPrefix("player01_steerright_", start: 1, end: 2, timePerFrame: 0.1)
        
        /*if playerState == .idle {
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
            swipeUp.direction = .up
            self.view?.addGestureRecognizer(swipeUp)
        }*/
        
        lightningOff = SKSpriteNode(imageNamed: "Lightning_00000")
        lightningOff.size = CGSize(width: 300, height: 311)
        lightningOff.zPosition = 4
        lightningOff.position = CGPoint(x: -150, y: 900)
        camera?.addChild(lightningOff)
        
        lightningOff2 = lightningOff.copy() as! SKSpriteNode
        lightningOff2.position = CGPoint(x: 0, y: 900)
        camera?.addChild(lightningOff2)
        
        lightningOff3 = lightningOff.copy() as! SKSpriteNode
        lightningOff3.position = CGPoint(x: 150, y: 900)
        camera?.addChild(lightningOff3)
        
        /*let lightning1 = setupButton(pictureBase: "Lightning_00000",
                                     pictureWidth: 300,
                                     pictureHeight: 311,
                                     buttonPositionX: -150,
                                     buttonPositionY: 900)
        
        let lightning2 = setupButton(pictureBase: "Lightning_00000",
                                     pictureWidth: 300,
                                     pictureHeight: 311,
                                     buttonPositionX: 0,
                                     buttonPositionY: 900)
        
        let lightning3 = setupButton(pictureBase: "Lightning_00000",
                                     pictureWidth: 300,
                                     pictureHeight: 311,
                                     buttonPositionX: 150,
                                     buttonPositionY: 900)
        camera?.addChild(lightning1)*/
        
        animationLoopUp = setupAnimationWithPrefix("Lightning_000",
                                                     start: 1,
                                                     end: 30,
                                                     timePerFrame: 0.02)
        
        animationLoopDown = setupAnimationWithPrefix("Lightning_000",
                                                         start: 31,
                                                         end: 45,
                                                         timePerFrame: 0.04)
        
        wait5 = SKAction.wait(forDuration: 5)
        wait3 = SKAction.wait(forDuration: 3)
        wait2 = SKAction.wait(forDuration: 2)
        wait1 = SKAction.wait(forDuration: 1)
        
        let lightning1Sequence = SKAction.sequence([animationLoopUp, wait5, animationLoopDown, wait1])
        let lightning2Sequence = SKAction.sequence([wait1, animationLoopUp, wait3, animationLoopDown, wait2])
        let lightning3Sequence = SKAction.sequence([wait2, animationLoopUp, wait1, animationLoopDown, wait3])
        
        lightningOff.run(SKAction.repeatForever(lightning1Sequence), withKey: "lightning1")
        lightningOff2.run(SKAction.repeatForever(lightning2Sequence), withKey: "lightning2")
        lightningOff3.run(SKAction.repeatForever(lightning3Sequence), withKey: "lightning3")
        
        
        //Make these actual Game Score Labels
        /*jumpLabel.fontColor = SKColor.white
        jumpLabel.fontSize = 50
        jumpLabel.zPosition = 100
        jumpLabel.position = CGPoint(x: 300, y: 800)
        camera?.addChild(jumpLabel)*/
        
        scoreLabel.fontColor = SKColor.white
        scoreLabel.fontSize = 200
        scoreLabel.zPosition = 8 //6
        scoreLabel.position = CGPoint(x: 0, y: 600)//(x: 475, y: 850)
        camera?.addChild(scoreLabel)
        
        //let scoreText = String(format: "%02d", score)

        /*if jumpState == .small {
            powerBarColor("GreenPower")
        } else if jumpState == .medium {
            powerBarColor("YellowPower")
        } else if jumpState == .big {
            powerBarColor("RedPower")
        }*/
        
        startGame()

        
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        
        if playerState == .idle {
            if gesture.direction == UISwipeGestureRecognizerDirection.up {
                if jumpState == .small {
                    //jumpLabel.text = "Jump"
                    jumpPlayer()
                } else if jumpState == .medium {
                    //jumpLabel.text = "Boost"
                    boostPlayer()
                } else if jumpState == .big {
                    //jumpLabel.text = "Super Boost"
                    superBoostPlayer()
                }
                jumpState = .noJump
            }
        }
        
        if playerState == .jump {
            if gesture.direction == UISwipeGestureRecognizerDirection.left {
                print("left")
                //player.xScale = -abs(xScale)
            } else if gesture.direction == UISwipeGestureRecognizerDirection.right {
                print("right")
            }
        }
    }
    
    func setupNodes() {
        let worldNode = childNode(withName: "World")!
        bgNode = worldNode.childNode(withName: "Background")!
        backgroundOverlayTemplate = bgNode.childNode(withName: "Overlay")!.copy() as! SKNode
        backgroundOverlayHeight = backgroundOverlayTemplate.calculateAccumulatedFrame().height
        fgNode = worldNode.childNode(withName: "Foreground")!
        player = fgNode.childNode(withName: "Player") as! SKSpriteNode
        //fgNode.childNode(withName: "Bomb")?.run(SKAction.hide())
        
        
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
        
        
        /*coin = loadCoin("Coin")
        coinSpecial = loadCoin("CoinSpecial")*/
        
        //platform = loadPlatform("Platform")
        
        /*coinArrow = loadCoinOverlayTemplate("CoinArrow")
        coin5Across = loadCoinOverlayTemplate("Coin5Across")
        coinS5Across = loadCoinOverlayTemplate("CoinS5Across")
        coinCross = loadCoinOverlayTemplate("CoinCross")
        coinSCross = loadCoinOverlayTemplate("CoinSCross")
        coinSArrow = loadCoinOverlayTemplate("CoinSArrow")
        coinDiagonal = loadCoinOverlayTemplate("CoinDiagonal")
        coinSDiagonal = loadCoinOverlayTemplate("CoinSDiagonal")*/
        
        addChild(cameraNode)
        camera = cameraNode
        
        
        
        setupLava()
        setupBackground("Background.sks")
        
        /*playButton = Button(defaultButtonImage: "PlayButton_00000", activeButtonImage: "PlayButton_00024", buttonAction: startGame)
        playButton.position = CGPoint(x: 0, y: -150)
        playButton.alpha = 0.01
        playButton.zPosition = 10
        fgNode.addChild(playButton)
        
        reviewButton = Button(defaultButtonImage: "ReviewStar_00000", activeButtonImage: "ReviewStar_00030", buttonAction: appStorePage)
        reviewButton.position = CGPoint(x: -385, y: -500)
        reviewButton.alpha = 0.01
        reviewButton.zPosition = 10
        fgNode.addChild(reviewButton)
        
        tutorialButton = Button(defaultButtonImage: "ReviewStar_00000", activeButtonImage: "ReviewStar_00030", buttonAction: showTutorialScene)
        tutorialButton.position = CGPoint(x: 0, y: -400)
        tutorialButton.alpha = 0.01
        tutorialButton.zPosition = 10
        fgNode.addChild(tutorialButton)
        
        noAdsStart = Button(defaultButtonImage: "NoAds_00000", activeButtonImage: "NoAds_00000", buttonAction: removeAds)
        noAdsStart.position = CGPoint(x: 385, y: -500)
        noAdsStart.alpha = 0.01
        noAdsStart.zPosition = 10
        fgNode.addChild(noAdsStart)*/
        
        /*setupBackground("BlueRain.sks")
        setupBackground("GreenRain.sks")
        setupBackground("YellowRain.sks")
        setupBackground("OrangeRain.sks")
        setupBackground("PinkRain.sks")*/
        
        // Squash and Stretch Player
        /*let squash = SKAction.scaleX(to: 1.15, y: 0.85, duration: 0.25)
        squash.timingMode = .easeInEaseOut
        let stretch = SKAction.scaleX(to: 0.85, y: 1.15, duration: 0.25)
        stretch.timingMode = .easeInEaseOut
        
        squashAndStetch = SKAction.sequence([squash, stretch])*/
    }
    

    
    func requestReview() {
        SKStoreReviewController.requestReview()
    }
    
    func setupLevel() {
        /*let overlayScene = SKScene(fileNamed: fileName)!
        let overlayTemplate = overlayScene.childNode(withName: "Overlay")
        return overlayTemplate as! SKSpriteNode*/
        /*overlay.enumerateChildNodes(withName: "PlatformMid") { (node, stop) in
            var newNode = SKSpriteNode()
            self.yellowPlatformAnimation = self.setupAnimationWithPrefix("YellowPlatform_000",
                                                                         start: 1,
                                                                         end: 80,
                                                                         timePerFrame: 0.05)
            newNode = SKSpriteNode(imageNamed: "YellowPlatform_00000")
            newNode.run(SKAction.repeatForever(self.yellowPlatformAnimation))
            newNode.size = CGSize(width: 350, height: 27)
            newNode.zPosition = 1
            newNode.position = node.position
            overlay.addChild(newNode)
            node.removeFromParent()
        }*/

        
        // Place initial platform
        let initialPlatform = startPlatform.copy() as! SKSpriteNode
        startPlatformAnimation = setupAnimationWithPrefix("StartPlatform_000",
                                                                    start: 1,
                                                                    end: 30,
                                                                    timePerFrame: 0.05)
        
        initialPlatform.size = CGSize(width: 1536, height: 300)
        initialPlatform.zPosition = 1
        
        var overlayPosition = CGPoint(x: 0, y: 0)//player.position
        
        //Made platform height up to match the anchor point of the player.
        //Changed ((player.size.height * 0.5) to ((player.size.height * 0.316)
        overlayPosition.y = -120/*player.position.y -
            ((player.size.height * 0.316) +
            (initialPlatform.size.height * 0.20))*/
        initialPlatform.position = CGPoint(x: 0, y: 0)//overlayPosition
        fgNode.addChild(initialPlatform)
        //print("*** Overlay Position (\(initialPlatform.position.x),\(initialPlatform.position.y))")
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
        
        /*let fileUrl = Bundle.main.url(forResource: "Title_1", withExtension: "mov")!
        avPlayer = AVPlayer(url: fileUrl)
        video = SKVideoNode(avPlayer: avPlayer)
        
        video.name = "TitleVideo"
        video.size = CGSize(width: 1018, height: 368)
        video.position = CGPoint(x: 0, y: 515)
        video.zPosition = 1000
        fgNode.addChild(video)
        video.play()*/
    }
    
    /*func findChild() {
        if (fgNode.childNode(withName: "TitleVideo") != nil) {
            print("Added to Scene")
        } else {
            print("nope")
        }
    }*/
    
    func setupPlayer() {
        //let catTexture = SKTexture(imageNamed: "NLCat_Fall_2")
        //player.physicsBody = SKPhysicsBody(texture: catTexture, size: CGSize(width: 150, height: 130))
        player.physicsBody = SKPhysicsBody(circleOfRadius: 60, center: CGPoint(x: 0.5, y: 0.25))
        //(circleOfRadius: player.size.width * 0.25)
        player.physicsBody!.isDynamic = false
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player //Invincible
        player.physicsBody!.collisionBitMask = PhysicsCategory.NoSpikePlatform
        //player.physicsBody!.collisionBitMask = PhysicsCategory.FallOff
        player.physicsBody!.restitution = 0
        player.physicsBody!.affectedByGravity = false //DEBUG - Turned off player gravity
        player.physicsBody?.linearDamping = 1.0
        player.physicsBody?.friction = 1.0
        
        //playerTrail = addTrail(name: "PlayerTrail")
    }
    
    func setupLava() {
        lava = fgNode.childNode(withName: "Lava") as! SKSpriteNode
        /*let emitter = SKEmitterNode(fileNamed: "SpikeSpark.sks")!
        emitter.particlePositionRange = CGVector(dx: size.width * 1.125, dy: 0.0)
        emitter.advanceSimulationTime(3.0)
        lava.addChild(emitter)*/
    }
    
    func setupBackground(_ fileName: String) {
        let emitter = SKEmitterNode(fileNamed: fileName)!
        emitter.particlePositionRange = CGVector(dx: size.width * 1.125, dy: size.height * 2)//505.0)
        emitter.advanceSimulationTime(3.0)
        camera?.addChild(emitter)
    }
    
    func spawnPowerUp(moveDuration: TimeInterval) {
       
            catNipBullet = SKSpriteNode(imageNamed: "Lightning_00028")
            
            catNipBullet.position = CGPoint(
                x: random(min: 300, max: 500),//self.size.width),
                y: self.size.height + camera!.position.y - 768)
            
            //print("scene y: \(self.size.height + camera!.position.y - 768)")
            //print("scene x: Left: \(-self.size.width) Right:\(self.size.width)")
            
            //print("camera x: \(camera!.position.x), camera y: \(camera!.position.y)")
            
            
            catNipBullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 128, height: 128))
            catNipBullet.physicsBody?.affectedByGravity = false
            catNipBullet.physicsBody?.isDynamic = false
            catNipBullet.physicsBody?.allowsRotation = true
            catNipBullet.physicsBody?.categoryBitMask = PhysicsCategory.CatNip
            catNipBullet.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            catNipBullet.physicsBody?.collisionBitMask = 0
            catNipBullet.zPosition = 6
            catNipBullet.yScale = 0.75
            catNipBullet.xScale = 0.75
            //catNipBullet.name = "catNipBullet"
            addChild(catNipBullet)
            
            let moveVector = CGVector(dx: 0, dy: -3000)
            let catNipBulletMoveAction = SKAction.move(by: moveVector, duration: moveDuration)
            let catNipBulletRepeat = SKAction.repeatForever(catNipBulletMoveAction)
            catNipBullet.run(catNipBulletRepeat)
            
            catNipBullet.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi/4.0, duration: 0.25)))
            
            if !isNodeVisible(catNipBullet, positionY: catNipBullet.position.y) {
                catNipBullet.removeFromParent()
            }
            
            print("Cat Nip Category: \(String(describing: catNipBullet.physicsBody?.categoryBitMask))")
            
            /*SKAction.repeat(
             SKAction.sequence([
             SKAction.run(SKAction.move),
             SKAction.wait(forDuration: 0.1)
             ]),
             count: 1)*/
        }
    
    
    func spawnShooter(moveDuration: TimeInterval) {
        deadFishBullet = SKSpriteNode(imageNamed: "DeadFish_00015")
        
        deadFishBullet.position = CGPoint(
            x: random(min: 300, max: 500),//self.size.width),
            y: self.size.height + camera!.position.y - 768)
        
        //print("scene y: \(self.size.height + camera!.position.y - 768)")
        //print("scene x: Left: \(-self.size.width) Right:\(self.size.width)")
        
        //print("camera x: \(camera!.position.x), camera y: \(camera!.position.y)")
        
        
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
        //deadFishBullet.name = "deadFishBullet"
        addChild(deadFishBullet)
        
        let moveVector = CGVector(dx: 0, dy: -3000)
        let deadFishBulletMoveAction = SKAction.move(by: moveVector, duration: moveDuration)
        let deadFishBulletRepeat = SKAction.repeatForever(deadFishBulletMoveAction)
        deadFishBullet.run(deadFishBulletRepeat)
        
        self.deadFishAnimation = self.setupAnimationWithPrefix("DeadFish_000",
                                                                   start: 15,
                                                                   end: 45,
                                                                   timePerFrame: 0.02)
        //deadFishBullet.run(SKAction.repeatForever(self.deadFishAnimation))
        
        deadFishBullet.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi/4.0, duration: 0.25)))
        
        if !isNodeVisible(deadFishBullet, positionY: deadFishBullet.position.y) {
            deadFishBullet.removeFromParent()
        }
        
        /*SKAction.repeat(
            SKAction.sequence([
                SKAction.run(SKAction.move),
                SKAction.wait(forDuration: 0.1)
                ]),
            count: 1)*/
    }
    
    func addAnimationToOverlay(overlay: SKSpriteNode) {

        overlay.enumerateChildNodes(withName: "SpikeOutline") { (node, stop) in
            let newNode = SKSpriteNode()
            /*if let nodePhysicsBody = node.physicsBody {
                switch nodePhysicsBody.categoryBitMask {
                /*case PhysicsCategory.PlatformBreakable:
                    //newNode = self.platform.copy() as! SKSpriteNode
                    newNode.size = CGSize(width: 215, height: 150)
                    newNode.run(SKAction.repeatForever(self.breakAnimation))
                    newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 128, height: 64))
                    newNode.physicsBody?.isDynamic = false
                    newNode.physicsBody?.affectedByGravity = false
                    newNode.physicsBody?.allowsRotation = false
                    newNode.physicsBody!.categoryBitMask = PhysicsCategory.PlatformBreakable
                    newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player*/
                case PhysicsCategory.Spikes:*/
                        let spikeBodyTexture = SKTexture(imageNamed: "SpikeOutline")
                        newNode.physicsBody = SKPhysicsBody(texture: spikeBodyTexture, size: CGSize(width: 190/*196*/, height: 100/*120*/))
                        newNode.physicsBody?.isDynamic = false
                        newNode.physicsBody?.affectedByGravity = false
                        newNode.physicsBody?.allowsRotation = false
                        newNode.physicsBody!.categoryBitMask = PhysicsCategory.Spikes
                        newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
                    
               /* default:
                    newNode = node.copy() as! SKSpriteNode*/
                //}
                newNode.position = node.position
                overlay.addChild(newNode)
                node.removeFromParent()
            //}
            
        }
        
        /*overlay.enumerateChildNodes(withName: "standardPlatform") { (node, stop) in
            var newNode = SKSpriteNode()
            if let nodePhysicsBody = node.physicsBody {
                switch nodePhysicsBody.categoryBitMask {
                case PhysicsCategory.PlatformBreakable:
                    //newNode = self.platform.copy() as! SKSpriteNode
                    newNode = SKSpriteNode(imageNamed: "StandardPlatform")
                    newNode.size = CGSize(width: 211, height: 147)
                    //newNode.run(SKAction.repeatForever(self.breakAnimation))
                    newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 128, height: 64))
                    newNode.physicsBody?.isDynamic = false
                    newNode.physicsBody?.affectedByGravity = false
                    newNode.physicsBody?.allowsRotation = false
                    newNode.physicsBody!.categoryBitMask = PhysicsCategory.PlatformBreakable
                    newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
                default:
                    newNode = node.copy() as! SKSpriteNode
                }
                newNode.position = node.position
                overlay.addChild(newNode)
                node.removeFromParent()
            }
            
        }*/
        
       /*overlay.enumerateChildNodes(withName: "PoisonBeaker") { (node, stop) in
            var newNode = SKSpriteNode()
            if let nodePhysicsBody = node.physicsBody {
                switch nodePhysicsBody.categoryBitMask {
                case PhysicsCategory.Poison:
                    newNode =  SKSpriteNode(imageNamed: "NLPoisonBeaker")
                    newNode.size = CGSize(width: 148.5, height: 187.5)
                    //newNode.run(SKAction.repeatForever(self.breakAnimation))
                    newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 93.75, height: 127.5))
                    newNode.physicsBody?.isDynamic = false
                    newNode.physicsBody?.affectedByGravity = false
                    newNode.physicsBody?.allowsRotation = false
                    newNode.physicsBody!.categoryBitMask = PhysicsCategory.Poison
                    newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
                    newNode.run(SKAction.repeatForever(self.poisonBeakerSequence))
                    let emitter = SKEmitterNode(fileNamed: "Poison")!
                    newNode.addChild(emitter)
                default:
                    newNode = node.copy() as! SKSpriteNode
                }
                newNode.position = node.position
                overlay.addChild(newNode)
                node.removeFromParent()
            }
        }*/
        
        /*overlay.enumerateChildNodes(withName: "Spikes") { (node, stop) in
            var newNode = SKSpriteNode()
            if let nodePhysicsBody = node.physicsBody {
                switch nodePhysicsBody.categoryBitMask {
                case PhysicsCategory.Spikes:
                    newNode =  SKSpriteNode(imageNamed: "Spikes")
                    newNode.size = CGSize(width: 193, height: 52)
                    //newNode.zRotation = 90
                    //newNode = self.platform.copy() as! SKSpriteNode
                    //newNode.size = CGSize(width: 232, height: 113)
                    //newNode.run(SKAction.repeatForever(self.lightningAnimation))
                    newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 150, height: 30))
                    newNode.physicsBody?.isDynamic = false
                    newNode.physicsBody?.affectedByGravity = false
                    newNode.physicsBody?.allowsRotation = false
                    newNode.physicsBody!.categoryBitMask = PhysicsCategory.Spikes
                    newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
                    
                default:
                    newNode = node.copy() as! SKSpriteNode
                }
                newNode.position = node.position
                overlay.addChild(newNode)
                node.removeFromParent()
            }
        }*/
        
        /*overlay.enumerateChildNodes(withName: "PlatformLow") { (node, stop) in
            var newNode = SKSpriteNode()
            if let nodePhysicsBody = node.physicsBody {
                switch nodePhysicsBody.categoryBitMask {
                case PhysicsCategory.PlatformLow:
                    newNode = SKSpriteNode(imageNamed: "BluePlatform_00000")
                    newNode.run(SKAction.repeatForever(self.poisonBeakerSequence))
                    newNode.size = CGSize(width: 200, height: 15)
                    newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 15))
                    
                    //newNode = self.platform.copy() as! SKSpriteNode
                    newNode.physicsBody?.isDynamic = false
                    newNode.physicsBody?.affectedByGravity = false
                    newNode.physicsBody?.allowsRotation = false
                    
                    newNode.zPosition = 99
                    
                    
                    /*newNode =  SKSpriteNode(imageNamed: "NLPoisonBeaker")
                    newNode.size = CGSize(width: 148.5, height: 187.5)
                    //newNode.run(SKAction.repeatForever(self.breakAnimation))
                    newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 93.75, height: 127.5))
                    newNode.physicsBody?.isDynamic = false
                    newNode.physicsBody?.affectedByGravity = false
                    newNode.physicsBody?.allowsRotation = false
                    newNode.physicsBody!.categoryBitMask = PhysicsCategory.Poison
                    newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
                    newNode.run(SKAction.repeatForever(self.poisonBeakerSequence))
                    let emitter = SKEmitterNode(fileNamed: "Poison")!
                    newNode.addChild(emitter)*/
                    
                default:
                    newNode = node.copy() as! SKSpriteNode
                }
                newNode.position = node.position
                overlay.addChild(newNode)
                node.removeFromParent()
            }
        }*/
        
        overlay.enumerateChildNodes(withName: "PlatformLow") { (node, stop) in
                    var newNode = SKSpriteNode()
                    self.bluePlatformAnimation = self.setupAnimationWithPrefix("BluePlatformLt_000",
                                                                         start: 15,
                                                                         end: 45,
                                                                         timePerFrame: 0.02)
                    newNode = SKSpriteNode(imageNamed: "BluePlatformLt_00000")
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
                    //print("PF Low: \(node.position)")
                    node.removeFromParent()
            
        }
        
        overlay.enumerateChildNodes(withName: "PlatformMid") { (node, stop) in
            var newNode = SKSpriteNode()
            self.yellowPlatformAnimation = self.setupAnimationWithPrefix("YellowPlatformLt_000",
                                                                       start: 00,
                                                                       end: 30,
                                                                       timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "YellowPlatformLt_00000")
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
            //print("PF Mid: \(node.position)")
            node.removeFromParent()
            
        }
        
        overlay.enumerateChildNodes(withName: "PlatformHigh") { (node, stop) in
            var newNode = SKSpriteNode()
            self.pinkPlatformAnimation = self.setupAnimationWithPrefix("PinkPlatformLt_000",
                                                                       start: 30,
                                                                       end: 60,
                                                                       timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "PinkPlatformLt_00000")
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
            //print("PF High: \(node.position)")
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
                
                //print("PF Dead: \(node.position)")
                node.removeFromParent()
            }
        
        /*overlay.enumerateChildNodes(withName: "LightningTrap") { (node, stop) in
            var newNode = SKSpriteNode()
            self.lightningTrapAnimation = self.setupAnimationWithPrefix("LightningTrap_000",
                                                                       start: 1,
                                                                       end: 30,
                                                                       timePerFrame: 0.02)
            newNode = SKSpriteNode(imageNamed: "LightningTrap_00000")
            newNode.run(SKAction.repeatForever(self.lightningTrapAnimation))
            newNode.size = CGSize(width: 380, height: 90)
            newNode.zPosition = 1
            newNode.zRotation = 48
            newNode.position = node.position
            overlay.addChild(newNode)
            
            newNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 265, height: 30))
            newNode.physicsBody?.isDynamic = false
            newNode.physicsBody?.affectedByGravity = false
            newNode.physicsBody?.allowsRotation = false
            newNode.physicsBody!.categoryBitMask = PhysicsCategory.Spikes
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player
            
            node.removeFromParent()
        }*/
        
        overlay.enumerateChildNodes(withName: "Mouse") { (node, stop) in
            var newNode = SKSpriteNode()
            /*self.lightningTrapAnimation = self.setupAnimationWithPrefix("LightningTrap_000",
                                                                        start: 1,
                                                                        end: 30,
                                                                        timePerFrame: 0.02)*/
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
            newNode.physicsBody!.contactTestBitMask = PhysicsCategory.Player | PhysicsCategory.Invincible
        
            node.removeFromParent()
        }

        
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
    
    /*func powerBarColor(_ color: String) {
        
        powerBar = SKSpriteNode(imageNamed: color)
        //powerBar.position = CGPoint(x: 0, y: 1000)
        powerBar.zPosition = 100
        
        switch color {
            case "GreenPower":
                powerBar.position = CGPoint(x: 0, y: 1000)
                camera?.addChild(powerBar)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.powerBar.removeFromParent()
                })
            case "YellowPower":
                powerBar.position = CGPoint(x: 0, y: 975)
                camera?.addChild(powerBar)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.powerBar.removeFromParent()
                })
            case "RedPower":
                powerBar.position = CGPoint(x: 0, y: 950)
                camera?.addChild(powerBar)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                    self.powerBar.removeFromParent()
                })
        default:
            powerBar.position = CGPoint(x: 0, y: 950)
        }
        /*if color == "GreenPower" {
            powerBar.position = CGPoint(x: 0, y: 1000)
        } else if color == "YellowPower" {
            powerBar.position = CGPoint(x: 0, y: 975)
        } else if color == "RedPower" {
            powerBar.position = CGPoint(x: 0, y: 950)
        }*/
        

    }*/
    
    func sceneCropAmount() -> CGFloat {
        guard let view = self.view else {
            return 0
        }
        let scale = view.bounds.size.height / self.size.height
        let scaledWidth = self.size.width * scale
        let scaledOverlap = scaledWidth - view.bounds.size.width
        return scaledOverlap / scale
    }
    
    /*func playerInvincible() {
        //let catTexture = SKTexture(imageNamed: "NLCat_Jump_1")
        //player.physicsBody = SKPhysicsBody(texture: catTexture, size: CGSize(width: 200, height: 170))
        player.physicsBody = SKPhysicsBody(circleOfRadius: 60, center: CGPoint(x: 0.5, y: 0.25))
        //(circleOfRadius: player.size.width * 0.25)
        player.physicsBody!.isDynamic = false
        player.physicsBody!.allowsRotation = false
        player.physicsBody!.categoryBitMask = PhysicsCategory.Player
        player.physicsBody!.collisionBitMask = PhysicsCategory.noSpikePlatform
        //player.physicsBody!.collisionBitMask = PhysicsCategory.FallOff
        player.physicsBody!.restitution = 0
        player.physicsBody!.affectedByGravity = false //DEBUG - Turned off player gravity
        
        if playerState == .invincible {
            
        }
    }*/
    
    func updatePlayer() {
        
        // Set velocity based on core motion
        //player.physicsBody?.velocity.dx = xAcceleration * 1000.0
        
        // Wrap player around edges of screen
        var playerPosition = convert(player.position, from: fgNode)
        let leftLimit = sceneCropAmount()/2 - player.size.width/2
        let rightLimit = size.width - sceneCropAmount()/2 + player.size.width/2
        if playerPosition.x < leftLimit {
            playerPosition = convert(CGPoint(x: rightLimit, y: 0.0), to: fgNode)
            player.position.x = playerPosition.x
        }
        else if playerPosition.x > rightLimit {
            playerPosition = convert(CGPoint(x: leftLimit, y: 0.0), to: fgNode)
            player.position.x = playerPosition.x
        }
        // Check player state
        //Turn this back on when you want to add player trail
        if player.physicsBody!.velocity.dy < CGFloat(0.0) && playerState != .fall {
            playerState = .fall
            /*if playerTrail.particleBirthRate == 0 {
                playerTrail.particleBirthRate = 200
            }*/
            //player.run(squashAndStetch)
        } else if player.physicsBody!.velocity.dy > CGFloat(0.0) && playerState != .jump {
            playerState = .jump
            //onPlatform = false
            //player.run(squashAndStetch)
        }
        
        // Animate player
        if playerState == .jump {
            if abs(player.physicsBody!.velocity.dx) > 100.0 {
                if player.physicsBody!.velocity.dx > 0 {
                    //runPlayerAnimation(playerAnimationSteerRight)
                } else {
                    //player.xScale = -1.0
                    //player.xScale = -abs(player.xScale)
                    //runPlayerAnimation(playerAnimationSteerLeft)
                }
            } else {
                runPlayerAnimation(playerAnimationJump)
            }
            } else if playerState == .fall {
                runPlayerAnimation(playerAnimationFall)
            } else if playerState == .idle {
                runPlayerAnimation(playerAnimationPlatform)
            }
        
            if invincible == true {
                invincibleTrail = addTrail(name: "InvincibleTrail")
                invincibleTrailAttached = true
            } else if invincible == false && invincibleTrailAttached == true {
                player.removeAllChildren()
                player.physicsBody?.categoryBitMask = PhysicsCategory.Player
                invincibleTrailAttached = false
        }
        
        //print("Player Category: \(String(describing: player.physicsBody?.categoryBitMask))")
        }
    
    func updateCamera() {
        
        //guard let camera = camera, let view = view else { return }
        
        // 1
        let cameraTarget = convert(player.position, from: fgNode)
        // 2
        var targetPositionY = cameraTarget.y + 600 - (size.height * 0.10)
        let lavaPos = convert(lava.position, from: fgNode)
        targetPositionY = max(targetPositionY, lavaPos.y)
        // 3
        let diff = targetPositionY - (camera?/*!*/.position.y)!
        //4
        let cameraLagFactor = CGFloat(0.2)
        let lagDiff = diff * cameraLagFactor
        let newCameraPositionY = (camera?/*!*/.position.y)! + lagDiff
        
        // 5
        camera?/*!*/.position.y = newCameraPositionY
        
        /*var targetPositionX = cameraTarget.x// - (size.width * 0.25)
        //targetPositionX = max(targetPositionX, targetPositionX - 500//lavaPos.x)
        // 3
        let diffX = targetPositionX - camera/*!*/.position.x
        //4
        let cameraLagFactorX = CGFloat(0.2)
        let lagDiffX = diffX * cameraLagFactorX
        let newCameraPositionX = camera/*!*/.position.x + lagDiffX
        
        // 5
        camera/*!*/.position.x = newCameraPositionX*/
        
        /*let zeroDistance = SKRange(constantValue: 0)
        let playerConstraint = SKConstraint.distance(zeroDistance, to: player)
        
        let xInset = min(sceneCropAmount()/2 - player.size.width/2, size.width - sceneCropAmount()/2 + player.size.width/2)
                         /*min(view.bounds.width/2 * camera.xScale, bgNode.frame.width/2 + 500)*/
        
        /*min((view?.bounds.width)!/2 * (camera?.xScale)!,
                         fgNode.frame.width/2)*/
        let yInset = 0
            //min(view.bounds.height/2 * camera.yScale,bgNode.frame.height/2)
        
        let constraintRect = bgNode.frame.insetBy(dx: xInset, dy: CGFloat(yInset))
        
        let xRange = SKRange(lowerLimit: constraintRect.minX,
                             upperLimit: constraintRect.maxX)
        let yRange = SKRange(lowerLimit: constraintRect.minY,
                             upperLimit: constraintRect.maxY)
        
        let edgeConstraint = SKConstraint.positionX(xRange, y: yRange)
        edgeConstraint.referenceNode = bgNode
        
        camera/*?*/.constraints = [playerConstraint,edgeConstraint]*/
        
        //print(camera.position.x)
        
        /*var playerPosition = convert(player.position, from: fgNode)
        let leftLimit = sceneCropAmount()/2 - player.size.width/2
        let rightLimit = size.width - sceneCropAmount()/2 + player.size.width/2
        if playerPosition.x < leftLimit {
            playerPosition = convert(CGPoint(x: rightLimit, y: 0.0), to: fgNode)
            player.position.x = playerPosition.x
        }
        else if playerPosition.x > rightLimit {
            playerPosition = convert(CGPoint(x: leftLimit, y: 0.0), to: fgNode)
            player.position.x = playerPosition.x
        }*/
    }
    
    func updateLava(_ dt: TimeInterval) {
        
        let bottomOfScreenY = camera!.position.y - (size.height / 2)
        
        let bottomOfScreenYFg = convert(CGPoint(x: 0, y: bottomOfScreenY), to: fgNode).y
        
        var lavaVelocityY = CGFloat(0)//CGFloat(300)
        
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
    
    func updateCollisionLava() {
        if player.position.y < lava.position.y - 500 {
            if playerState != .lava {
                playerState = .lava
                playerTrail.particleBirthRate = 0
                /*let smokeTrail = addTrail(name: "SmokeTrail")
                run(SKAction.sequence([
                    soundHitLava,
                    SKAction.wait(forDuration: 3.0),
                    SKAction.run() {
                        self.removeTrail(trail: smokeTrail)
                    }
                    ]))*/
            }
            boostPlayer()
            //screenShakeByAmt(50) - DEBUG: Removed it because it was hard to see everytime I hit lava.
            lives -= 1
            if lives <= 0 {
                gameOver()
                //run(soundGameOver)
            }
        }
    }
    
    func updateExplosions(_ dt: TimeInterval) {
        timeSinceLastExplosion += dt
        if timeSinceLastExplosion > timeForNextExplosion {
            timeForNextExplosion = TimeInterval(CGFloat.random(min: 0.1, max: 0.5))
            timeSinceLastExplosion = 0
            
            //createRandomExplosion()
        }
    }
    
    func updatePowerUp(_ dt: TimeInterval) {
        catNipTimeSinceLastShot += dt
        
        //print("\(catNipTimeSinceLastShot)")
        
        var catNipMoveDuration = 0.0
        if catNipTimeSinceLastShot > catNipNextShot {
            switch score {
            case 0...14:
                catNipNextShot = TimeInterval(CGFloat.random(min: 5, max: 10))
                catNipMoveDuration = 5.0
            case 15...30:
                catNipNextShot = TimeInterval(CGFloat.random(min: 3, max: 5))
                catNipMoveDuration = 3.0
            case 31...60:
                catNipNextShot = TimeInterval(CGFloat.random(min: 3, max: 5))
                catNipMoveDuration = 4.0
            case 61...:
                catNipNextShot = TimeInterval(CGFloat.random(min: 3, max: 5))
                catNipMoveDuration = 5.0
            default:
                fatalError()
            }
            
            catNipTimeSinceLastShot = 0
            
            spawnPowerUp(moveDuration: catNipMoveDuration)
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
            
            //timeForNextShot = TimeInterval(CGFloat.random(min: 4, max: 6))
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
    
    func updateRedAlert(_ lastUpdateTime: TimeInterval) {
        // 1
        redAlertTime += lastUpdateTime
        let amt: CGFloat = CGFloat(redAlertTime) * π * 2.0 / 1.93725
        let colorBlendFactor = (sin(amt) + 1.0) / 2.0
        // 2
        for bgChild in bgNode.children {
            for node in bgChild.children {
                if let sprite = node as? SKSpriteNode {
                    let nodePos = bgChild.convert(sprite.position, to: self)
                    // 3
                    if !isNodeVisible(sprite, positionY: nodePos.y) {
                        sprite.removeFromParent()
                    } else {
                        sprite.color = SKColorWithRGB(255, g: 0, b: 0)
                        sprite.colorBlendFactor = colorBlendFactor
                    }
                }
            }
            // 4
            if bgChild.name == "Overlay" && bgChild.children.count == 0 {
                bgChild.removeFromParent()
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        //print("Attached: \(invincibleTrailAttached)")
        //print("Invincible: \(invincible)")
        // 1
        if lastUpdateTimeInterval > 0 {
            deltaTime = currentTime - lastUpdateTimeInterval
        } else {
            deltaTime = 0
        }
        lastUpdateTimeInterval = currentTime
        // 2
        if isPaused {
            return
        }
        // 3
        if gameState == .playing {
            updateCamera()
            updateLevel()
            updatePlayer()
            updateLava(deltaTime)
            //updateCollisionLava()
            updateExplosions(deltaTime)
            updateShooter(deltaTime)
            if score >= 15 {
                updatePowerUp(deltaTime)
            }
            //updateRedAlert(deltaTime)
            endInvincible(deltaTime)
            if platformState == .low || platformState == .middle || platformState == .high {
                scoreLabel.text = "\(score)"
                //print("Platform state is set")
            }
            if playerState != .idle {
                player.physicsBody?.affectedByGravity = true
            }
        }
        //print("\(invincible)")
        //print("\(playerState)")
        //print("\(player.position.y)")
    }
    
    func endInvincible(_ dt: TimeInterval) {
        if invincible == true {
                invincibleTime += dt
                print("\(invincibleTime)")
            if invincibleTime > 5 { //Invincible
                invincible = false
                player.physicsBody?.categoryBitMask = PhysicsCategory.Player
                invincibleTime = 0
            }
            
        }
    }
    
    func setPlayerVelocity(_ amount: CGFloat) {
        player.physicsBody!.velocity.dy =
            max(player.physicsBody!.velocity.dy, amount * gameGain)
        //print(player.physicsBody!.velocity.dy)
    }
    
    func jumpPlayer() {
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 550))
        //setPlayerVelocity(400) //400 to go 250 px
    }
    
    func boostPlayer() {
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 850))
        //setPlayerVelocity(550)
        //screenShakeByAmt(40)
    }
    
    func superBoostPlayer() {
        player.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 1100))
        //setPlayerVelocity(655)
    }
    
    // MARK: - Overlay nodes
    
    //1
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
    
    /*func loadCoinOverlayTemplate(_ fileName: String) -> SKSpriteNode {
        //1
        let overlayTemplate = loadForegroundOverlayTemplate(fileName)
        //2
        overlayTemplate.enumerateChildNodes(withName: "*", using: { (node, stop) in
            let coinPos = node.position
            let coin: SKSpriteNode
            //3
            if node.name == "special" {
                coin = self.coinSpecial.copy() as! SKSpriteNode
            } else {
                coin = self.coin.copy() as! SKSpriteNode
            }
            //4
            coin.position = coinPos
            overlayTemplate.addChild(coin)
            node.removeFromParent()
        })
        //5
        return overlayTemplate
    }*/
    
    //2
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
        let platformPercentage = 100//60
        
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
            } else {
                // Create breakable platform 25%
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
                case 16:
                    overlaySprite = level9
                case 17:
                    overlaySprite = level9
                case 18:
                    overlaySprite = level10
                case 19:
                    overlaySprite = level10
                    flipH = true
                default:
                    overlaySprite = level1
                }
            }
            createForegroundOverlay(overlaySprite, flipX: flipH)
        }
    }
    
    //3
    func createBackgroundOverlay() {
        let backgroundOverlay = backgroundOverlayTemplate.copy() as! SKNode
        backgroundOverlay.position = CGPoint(x: 0.0, y: levelPositionY)
        bgNode.addChild(backgroundOverlay)
        levelPositionY += backgroundOverlayHeight
    }
    
    // MARK: - Events
    
    /*func animatePlayer() -> Bool {
        
        switch cumulativeNumberOfTouches {
            case 1: print("small jump")//boostPlayer()
            case 2: print("medium jump") //superBoostPlayer()
            case 3: print("big jump")
            default: print("default")//cumulativeNumberOfTouches += 1
        }
        
        return true
    }*/
    
    /*func nextAnimation() {
        var playerAnimated = false
        repeat {
            cumulativeNumberOfTouches += 1
            if cumulativeNumberOfTouches > 3 {
                self.cumulativeNumberOfTouches = 1
            }
            //clickWait()
            playerAnimated = animatePlayer()
        } while !playerAnimated
    }*/
    
    var cumulativeNumberOfTouches = 0
    
    func updateTouchTime(_ lastUpdateTime: TimeInterval) {
        // 1
        touchTime += lastUpdateTime
        //print(touchTime)
        
        /*if touchTime >= 2 {
            print("small jump")
            print("you're awesome!!!")
        }*/
        //let amt: CGFloat = CGFloat(touchTime) * π * 2.0 / 1.93725
        /*let colorBlendFactor = (sin(amt) + 1.0) / 2.0
        // 2
        for bgChild in bgNode.children {
            for node in bgChild.children {
                if let sprite = node as? SKSpriteNode {
                    let nodePos = bgChild.convert(sprite.position, to: self)
                    // 3
                    if !isNodeVisible(sprite, positionY: nodePos.y) {
                        sprite.removeFromParent()
                    } else {
                        sprite.color = SKColorWithRGB(255, g: 0, b: 0)
                        sprite.colorBlendFactor = colorBlendFactor
                    }
                }
            }
            // 4
            if bgChild.name == "Overlay" && bgChild.children.count == 0 {
                bgChild.removeFromParent()
            }
        }*/
    }
    
    func showNewScene() {
            let newScene = GameScene(fileNamed: "GameScene")
            newScene!.scaleMode = .aspectFill
            let fade = SKTransition.fade(withDuration: 0.5)//SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: fade)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //isFingerOnCat = true

        
        /*if gameState == .waitingForTap {
            //startGame()
         //bombDrop()
         }else if gameState == .gameOver {
            showNewScene()
         }*/
        
        /*let greenPowerBar = SKSpriteNode(imageNamed: "GreenPower")
        let yellowPowerBar = SKSpriteNode(imageNamed: "YellowPower")
        let redPowerBar = SKSpriteNode(imageNamed: "RedPower")
        
        greenPowerBar.position = CGPoint(x: 0, y: 1000)
        yellowPowerBar.position = CGPoint(x: 0, y: 975)
        redPowerBar.position = CGPoint(x: 0, y: 950)
        
        greenPowerBar.setScale(0)
        yellowPowerBar.setScale(0)
        redPowerBar.setScale(0)
        
        greenPowerBar.zPosition = 100
        yellowPowerBar.zPosition = 100
        redPowerBar.zPosition = 100*/
        
        /*if gameState == .waitingForTap {
            startGame()
        }*/
        
        /*if gameState == .playing {
                let touch = touches.first
                tapCount = touch!.tapCount
                
                if playerState == .idle && platformState == .high {
                    //camera?.addChild(redPowerBar)
                    //camera?.addChild(yellowPowerBar)
                    //camera?.addChild(greenPowerBar)
                    //redPowerBar.run(SKAction.scale(to: 1, duration: 0.1))
                    if tapCount == 1 {
                        superBoostPlayer()
                    }
                } else if playerState == .idle && platformState == .middle {
                    //camera?.addChild(yellowPowerBar)
                    //yellowPowerBar.run(SKAction.scale(to: 1, duration: 0.1))
                    if tapCount == 1 {
                        boostPlayer()
                    }
                } else if playerState == .idle && platformState == .low {
                   // camera?.addChild(greenPowerBar)
                    //greenPowerBar.run(SKAction.scale(to: 1, duration: 0.1))
                    if tapCount == 1 {
                        jumpPlayer()
                    }
            }
            
            /*
             When the screen is tapped one time make the player crouch a little bit
             showing that he is about to make a jump. Do that each time the screen is tapped up to three.
             
             When the player swipes up, boost the player based on how many low the player is crouched or
             how many times the screen was pressed.
             
             I need to break(I think) after the switch statement if they player swipes early on for a smaller jump.
             
             I also need to loop through the statement like the 10x button restarts.
            */
            
            
            
            //nextAnimation()
            
           
            
        
            /*for touch in touches {
                let location = touch.location(in: self)
                let node = self.atPoint(location)
                
                if node == self {
                    
                    cumulativeNumberOfTouches += 1
                    
                    switch cumulativeNumberOfTouches {
                        case 1: boostPlayer()
                        case 2: superBoostPlayer()
                        default: print("default")
                    }
                    
                }
            }
            
            */
        }*/
        
        
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
                //print(touchDifference)
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
    /*override func(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .waitingForTap {
            bombDrop()
        } else if gameState == .gameOver {
            let newScene = GameScene(fileNamed: "GameScene")
            newScene!.scaleMode = .aspectFill
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
        }
    }*/
    
    func bombDrop() {

        
       /* // Bounce bomb
        let scaleUp = SKAction.scale(to: 1.25, duration: 0.25)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.25)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let repeatSeq = SKAction.repeatForever(sequence)
        fgNode.childNode(withName: "Bomb")!.run(SKAction.unhide())
        fgNode.childNode(withName: "Bomb")!.run(repeatSeq)
        run(SKAction.sequence([
            soundBombDrop,
            soundTickTock,
            SKAction.run(startGame)
            ]))*/
    }
    
    func startGame() {
        
        //gameState = .waitingForBomb
        // Scale out title & ready label
        let scale = SKAction.scale(to: 0, duration: 0.4)
        fgNode.childNode(withName: "Title")!.run(scale)
        fgNode.childNode(withName: "Ready")!.run(
            SKAction.sequence(
                [SKAction.wait(forDuration: 0.2), scale]))
        fgNode.childNode(withName: "Dimmer")!.run(SKAction.scale(to: 0, duration: 0.2))
        fgNode.childNode(withName: "Star")!.run(SKAction.scale(to: 0, duration: 0.2))
        fgNode.childNode(withName: "NoAds")!.run(SKAction.scale(to: 0, duration: 0.2))
        fgNode.childNode(withName: "Tutorial")!.run(SKAction.scale(to: 0, duration: 0.2))
        
        /*playButton.removeFromParent()
        reviewButton.removeFromParent()
        noAdsStart.removeFromParent()
        tutorialButton.removeFromParent()*/

        /*let bomb = fgNode.childNode(withName: "Bomb")!
        let bombBlast = explosion(intensity: 2.0)
        bombBlast.position = bomb.position
        fgNode.addChild(bombBlast)
        bomb.removeFromParent()
        run(soundExplosions[3])*/
        gameState = .playing
        playerState = .idle
        platformState = .high
        
        player.physicsBody!.isDynamic = true
        //superBoostPlayer()
        //playBackgroundMusic(name: "Spacebased.mp3")
        
        let lightningBack = SKSpriteNode(imageNamed: "Lightning_00000")
        lightningBack.size = CGSize(width: 300, height: 311)
        lightningBack.zPosition = 4
        lightningBack.position = CGPoint(x: -150, y: 900)
        camera?.addChild(lightningBack)
        
        let lightningBack2 = lightningBack.copy() as! SKSpriteNode
        lightningBack2.position = CGPoint(x: 0, y: 900)
        camera?.addChild(lightningBack2)
        
        let lightningBack3 = lightningBack.copy() as! SKSpriteNode
        lightningBack3.position = CGPoint(x: 150, y: 900)
        camera?.addChild(lightningBack3)
        
        lightningOff.removeFromParent()
        lightningOff2.removeFromParent()
        lightningOff3.removeFromParent()
        
        /*lightningOff.removeAction(forKey: "lightning1")
        lightningOff2.removeAction(forKey: "lightning2")
        lightningOff3.removeAction(forKey: "lightning3")*/
        
        
        let alarm = SKAudioNode(fileNamed: "alarm.wav")
        alarm.name = "alarm"
        alarm.autoplayLooped = true
        addChild(alarm)
        
        pointerHand = SKSpriteNode(imageNamed: "PointerHand")
        pointerHand.zPosition = 100
        pointerHand.position = CGPoint(x: -250, y: -650)
        pointerHand.setScale(0.5)
        camera?.addChild(pointerHand)
        let pointerMoveRight = SKAction.move(by: CGVector(dx: 500, dy: 0), duration: 0.5)
        let pointerMoveLeft = SKAction.move(by: CGVector(dx: -500, dy: 0), duration: 0.5)
        pointerHand.run(SKAction.repeatForever(SKAction.sequence([pointerMoveRight, pointerMoveLeft])))
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let scaleNumber = SKAction.scale(to: 6, duration: 1)
        let fadeOut = SKAction.fadeOut(withDuration: 1)
        let group = SKAction.group([/*fadeIn,*/scaleNumber,fadeOut])
        
        let goSign = SKSpriteNode(imageNamed: "Go_00000")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            goSign.zPosition = 100
            self.camera?.addChild(goSign)
            goSign.run(group)
            self.superBoostPlayer()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
            self.pointerHand.removeFromParent()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            goSign.removeFromParent()
        })
        
        //screenShakeByAmt(100)
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
        let moveUp = SKAction.moveBy(x: 0.0, y: 200/*size.height/2.0*/, duration: 0.2)
         moveUp.timingMode = .easeOut
         let moveDown = SKAction.moveBy(x: 0.0,
         y: -(size.height * 1.5),
         duration: 1.0)
         moveDown.timingMode = .easeIn
         player.run(SKAction.sequence([wait, moveUp, moveDown]))
        
        //let playerPosition = convert(player.position, from: fgNode)
        //let catOff = SKSpriteNode(imageNamed:"CatOff_00000")
        //let blast = explosion(intensity: 3.0)
        //catOff.position = playerPosition//camera!.position + CGPoint(x: 0, y: 400)
        //catOff.zPosition = 11
        //addChild(catOff)
        //run(soundExplosions[3])
        
        if pointerHand != nil {
            pointerHand.removeFromParent()
        }
        
        //self.playBackgroundMusic(name: "NeonLightBuzz.wav")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
            let smoothAction = SKAction.scale(to: 1, duration: 0.25)
            
            /*let gameOverSprite = SKSpriteNode(imageNamed: "GameOver2")
            gameOverSprite.size = CGSize(width: 1018, height: 368)
            gameOverSprite.position = camera!.position + CGPoint(x:0, y:400)
            gameOverSprite.zPosition = 10
            addChild(gameOverSprite)*/
            
            let restartButton = self.setupButton(pictureBase: "RestartButton_00040", pictureWidth: 335, pictureHeight: 357, buttonPositionX: -600/*-385*/, buttonPositionY: -600, zPosition: 8)
            
            let restartButtonAnimation = self.buttonAnimation(animationBase: "RestartButton_000", start: 40, end: 45, foreverStart: 46, foreverEnd: 60, startTimePerFrame: 0.035, foreverTimePerFrame: 0.035)
            
            let restartButtonTransparent = Button(defaultButtonImage: "NoAds_00010", activeButtonImage: "RestartButton_00030", buttonAction: self.showNewScene)
            restartButtonTransparent.position = CGPoint(x: -385, y: -600)
            restartButtonTransparent.alpha = 0.01
            restartButtonTransparent.zPosition = 10
            
            let restartMove = SKAction.moveBy(x: 215, y: 0, duration: 0.5)
            
            self.camera?.addChild(restartButtonTransparent)
            self.camera?.addChild(restartButton)
                //restartButton.setScale(0)
            restartButton.run(SKAction.sequence([restartMove,restartButtonAnimation]))
            
            
            let gameOverLabel = self.setupButton(pictureBase: "GameOver_00000", pictureWidth: 1100, pictureHeight: 600, buttonPositionX: -50, buttonPositionY: 1100/*575*/, zPosition: 8)
            
            let gameOverAnimation = self.buttonAnimation(animationBase: "GameOver_000", start: 1, end: 19, foreverStart: 20, foreverEnd: 35, startTimePerFrame: 0.035, foreverTimePerFrame: 0.035)
            
            let gameOverMove = SKAction.moveBy(x: 0, y: -775, duration: 0.5)
            
            self.camera?.addChild(gameOverLabel)
            gameOverLabel.run(SKAction.sequence([gameOverMove,gameOverAnimation]))
            
            let noAdsButton = self.setupButton(pictureBase: "NoAds_00000", pictureWidth: 335, pictureHeight: 357, buttonPositionX: 600, buttonPositionY: -600, zPosition: 8)
            
            let noAdsButtonAnimation = self.buttonAnimation(animationBase: "NoAds_000", start: 1, end: 2, foreverStart: 3, foreverEnd: 43, startTimePerFrame: 0.035, foreverTimePerFrame: 0.035)
            
            let noAdsButtonTransparent = Button(defaultButtonImage: "NoAds_00000", activeButtonImage: "NoAds_00000", buttonAction: self.mainMenu.removeAds)
            
            noAdsButtonTransparent.position = CGPoint(x: 385, y: -600)
            noAdsButtonTransparent.alpha = 0.01
            noAdsButtonTransparent.zPosition = 10
            
            let noAdsMove = SKAction.moveBy(x: -215, y: 0, duration: 0.5)
            
            self.camera?.addChild(noAdsButtonTransparent)
            self.camera?.addChild(noAdsButton)
            noAdsButton.run(SKAction.sequence([noAdsMove,noAdsButtonAnimation]))
            
            //let dimmerSpriteMove = SKAction.moveTo(y: 1024, duration: 0.5)
            let dimmerSprite = SKSpriteNode(imageNamed: "Dimmer")
            //dimmerSprite.size = CGSize(width:1526, height:2071)
            dimmerSprite.position = self.camera!.position
            dimmerSprite.zPosition = 7
            //dimmerSprite.setScale(0)
            self.addChild(dimmerSprite)
            //dimmerSprite.run(dimmerSpriteMove)
            
            
            //Restart Button
            /*buttonAnimation(animationBase: "RestartButton_000",
                            pictureBase: "RestartButton_00010",
                            start: 11,
                            end: 45,
                            foreverStart: 46,
                            foreverEnd: 60,
                            startTimePerFrame: 0.024,
                            foreverTimePerFrame: 0.071,
                            pictureWidth: 500,
                            pictureHeight: 533,
                            buttonPositionX: -300,
                            buttonPositionY: -600)*/
            
            //Game Over Label
            /*buttonAnimation(animationBase: "GameOver_000",
                            pictureBase: "GameOver_00000",
                            start: 1,
                            end: 19,
                            foreverStart: 20,
                            foreverEnd: 35,
                            startTimePerFrame: 0.024,
                            foreverTimePerFrame: 0.071,
                            pictureWidth: 1100,
                            pictureHeight: 600,
                            buttonPositionX: 0,
                            buttonPositionY: 400)*/
            
            
            
            //player = SKSpriteNode(imageNamed: "NLDeadCat")
            //addChild(player)
            
            if let alarm = self.childNode(withName: "alarm") {
                alarm.removeFromParent()
            }
            
            let highScoreLabel = SKLabelNode(fontNamed: "NeonTubes2-Regular")
            highScoreLabel.fontSize = 200
            highScoreLabel.position = CGPoint(x: 0, y: -225)
            highScoreLabel.zPosition = 8
            highScoreLabel.text = "BEST: \(UserDefaults().integer(forKey: "HIGHSCORE"))"
            self.camera?.addChild(highScoreLabel)
            
            if let viewController = self.view?.window?.rootViewController {
                if SwiftyAd.shared.isInterstitialReady {
                    SwiftyAd.shared.showInterstitial(from: viewController, withInterval: 5)
                }
            }
            
            // Requests user to make a review after losing, doesn't happen everytime. It is controlled by Apple.
            self.requestReview()
            
            //self.fgNode.removeAllChildren()
            })
    }
    
    func setupLights(lights: Int) {
        //Lightning 1
        let lightning1 = setupButton(pictureBase: "Lightning_00000", pictureWidth: 300, pictureHeight: 311, buttonPositionX: -150, buttonPositionY: 900, zPosition: 6)
        
        /*let animationLoop = setupAnimationWithPrefix("Lightning_000",
                                                   start: 1,
                                                   end: 45,
                                                   timePerFrame: 0.015/*0.024*/)*/
        
        /*let lightning1Animation = buttonAnimation(animationBase: "Lightning_000", start: 1, end: 17, foreverStart: 18, foreverEnd: 30, startTimePerFrame: 0.024, foreverTimePerFrame: 0.071)*/
        
        //Lightning 2
        let lightning2 = setupButton(pictureBase: "Lightning_00000", pictureWidth: 300, pictureHeight: 311, buttonPositionX: 0, buttonPositionY: 900, zPosition: 6)
        
        /*let lightning2Animation = buttonAnimation(animationBase: "Lightning_000", start: 1, end: 17, foreverStart: 18, foreverEnd: 30, startTimePerFrame: 0.024, foreverTimePerFrame: 0.071)*/
        
        //Lightning 3
        let lightning3 = setupButton(pictureBase: "Lightning_00000", pictureWidth: 300, pictureHeight: 311, buttonPositionX: 150, buttonPositionY: 900, zPosition: 6)
        
        /*let lightning3Animation = buttonAnimation(animationBase: "Lightning_000", start: 1, end: 17, foreverStart: 18, foreverEnd: 30, startTimePerFrame: 0.024, foreverTimePerFrame: 0.071)*/
        
        //let lightningSequence = SKAction.sequence([animationLoopUp, wait1, animationLoopDown])
        
        
        if lights == 1 {
            if onPlatform == true {
                camera?.addChild(lightning1)
                lightning1.run(animationLoopUp)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                lightning1.removeFromParent()
                //greenPowerBar.removeFromParent()
            })
        } else if lights == 2 {
            
            camera?.addChild(lightning1)
            lightning1.run(animationLoopUp)
            
            camera?.addChild(lightning2)
            lightning2.run(animationLoopUp)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                lightning1.removeFromParent()
                lightning2.removeFromParent()
                //greenPowerBar.removeFromParent()
                //yellowPowerBar.removeFromParent()
            })
        } else if lights == 3 {
            //Lightning 3
            camera?.addChild(lightning1)
            lightning1.run(animationLoopUp)
            
            camera?.addChild(lightning2)
            lightning2.run(animationLoopUp)
            
            camera?.addChild(lightning3)
            lightning3.run(animationLoopUp)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                lightning1.removeFromParent()
                lightning2.removeFromParent()
                lightning3.removeFromParent()
                //greenPowerBar.removeFromParent()
                //yellowPowerBar.removeFromParent()
                //redPowerBar.removeFromParent()
            })
        }
    }
    
    func playerPlatformSettings() {
        player.physicsBody?.isDynamic = true
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.physicsBody?.affectedByGravity = false
        playerState = .idle
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        /*let platformPosition = fgNode.convert(platform.position, to: scene!)
        let playerPosition = fgNode.convert(player.position, to: scene!)
        let limitJoint = SKPhysicsJointLimit.joint(withBodyA: player.physicsBody!, bodyB: platform.physicsBody!, anchorA: platformPosition, anchorB: playerPosition)*/
        
        //player.physicsBody?.affectedByGravity = true
        
        let other = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.CatNip:
            if invincible == false {
                invincible = true
                emitParticles(name: "LightningExplode", sprite: catNipBullet)
                player.physicsBody?.categoryBitMask = PhysicsCategory.Invincible
                //player.physicsBody?.contactTestBitMask = PhysicsCategory.Mouse
                run(powerUp)
                catNipBullet.removeFromParent()
            }
            
        case PhysicsCategory.PlatformLow:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            setupLights(lights: 1)
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .low
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
            setupLights(lights: 2)
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .middle
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
            setupLights(lights: 3)
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .high
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
            setupLights(lights: 1)
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .low
                    onPlatform = true
                    jumpPlayer()
                    run(soundJump)
                }
            }
            
        case PhysicsCategory.BackupMiddle:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            setupLights(lights: 2)
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .middle
                    run(soundJump)
                    boostPlayer()
                }
            }
            
        case PhysicsCategory.BackupHigh:
            if playerState == .jump {
                player.physicsBody?.affectedByGravity = true
            }
            setupLights(lights: 3)
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    playerPlatformSettings()
                    platformState = .high
                    superBoostPlayer()
                    run(soundJump)
                }
            }
            
        /*case PhysicsCategory.PlatformBreakable:
            if let platform = other.node as? SKSpriteNode {
                if player.physicsBody!.velocity.dy < 0 {
                    player.physicsBody?.isDynamic = true
                    player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                    player.physicsBody?.affectedByGravity = false
                    playerState = .idle
                    //platformAction(platform, breakable: true)
                    platform.physicsBody?.isDynamic = true
                    platform.physicsBody?.allowsRotation = true
                    platform.physicsBody?.affectedByGravity = true
                    platform.run(SKAction.removeFromParentAfterDelay(2.0))
                    
                    boostPlayer()
                    
                    //run(soundBrick)
                }
            }*/
        /*case PhysicsCategory.Poison:
            if let beaker = other.node as? SKSpriteNode {
                emitParticles(name: "PoisonExplode", sprite: beaker)
                gameOver()
            }*/
            
        case PhysicsCategory.Spikes:
            if let spike = other.node as? SKSpriteNode {
                //emitParticles(name: "Lightning", sprite: spike)
                    notification.notificationOccurred(.error)
                    gameOver()
                    run(electricute)
            }
        case PhysicsCategory.Lava:
                //emitParticles(name: "Lightning", sprite: spike)
            if invincible == false {
                gameOver()
                run(electricute)
            } else if invincible == true {
                superBoostPlayer()
                run(soundJump)
            }
            
        /*case PhysicsCategory.Mouse:
            if let mouse = other.node as? SKSpriteNode {
                emitParticles(name: "MouseExplode", sprite: mouse)
                run(mouseHit)
                score += 3
                print("Player Category: \(String(describing: player.physicsBody?.categoryBitMask))")
                print("Mouse Category: \(String(describing: mouse.physicsBody?.categoryBitMask))")
                mouse.removeFromParent()
            }*/
            
        default:
            break
        }
        
        if score > userDefaults.integer(forKey: "HIGHSCORE") {
            saveHighScore()
        }
    }
    
    func saveHighScore() {
        UserDefaults().set(score, forKey: "HIGHSCORE")
        
        if gameState == .gameOver {
            run(highScoreSound)
        }
        //print("\(UserDefaults().integer(forKey: "HIGHSCORE"))")
    }
    
    // MARK: - Particles
    
    /*func createRandomExplosion() {
        // 1
        let cameraPos = camera!.position
        let sceneSize = self.size
        
        let explosionPos = CGPoint(x: CGFloat.random(min: 0.0,
                                                     max: cameraPos.x * 2.0),
                                   y: CGFloat.random(min: cameraPos.y - sceneSize.height / 2,
                                                     max: cameraPos.y + sceneSize.height * 0.35))
        // 2
        let randomNum = Int.random(soundExplosions.count)
        run(soundExplosions[randomNum])
        // 3
        let explode = explosion(intensity: 0.25 * CGFloat(randomNum + 1))
        explode.position = convert(explosionPos, to: bgNode)
        explode.run(SKAction.removeFromParentAfterDelay(2.0))
        bgNode.addChild(explode)
        
        if randomNum == 3 {
            screenShakeByAmt(10)
        }
    }*/
    
    func didEnd(_ contact: SKPhysicsContact) {
        let other = contact.bodyA.categoryBitMask ==
            PhysicsCategory.Player ? contact.bodyB : contact.bodyA
        switch other.categoryBitMask {
        case PhysicsCategory.Mouse:
            if let mouse = other.node as? SKSpriteNode {
                emitParticles(name: "MouseExplode", sprite: mouse)
                run(mouseHit)
                score += 3
                print("Player Category: \(String(describing: player.physicsBody?.categoryBitMask))")
                print("Mouse Category: \(String(describing: mouse.physicsBody?.categoryBitMask))")
                mouse.removeFromParent()
            }
            
        default:
            break
            }

            
 
        }
    
    func explosion(intensity: CGFloat) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        let particleTexture = SKTexture(imageNamed: "Lightning_00028")
        emitter.zPosition = 2
        emitter.particleTexture = particleTexture
        emitter.particleBirthRate = 4000 * intensity
        emitter.numParticlesToEmit = Int(400 * intensity)
        emitter.particleLifetime = 2.0
        emitter.emissionAngle = CGFloat(90.0).degreesToRadians()
        emitter.emissionAngleRange = CGFloat(360.0).degreesToRadians()
        emitter.particleSpeed = 600 * intensity
        emitter.particleSpeedRange = 1000 * intensity
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.25
        emitter.particleScale = 1.2
        emitter.particleScaleRange = 2.0
        emitter.particleScaleSpeed = -1.5
        //emitter.particleColor = SKColor.orange
        emitter.particleColorBlendFactor = 1
        emitter.particleBlendMode = SKBlendMode.add
        emitter.run(SKAction.removeFromParentAfterDelay(2.0))
    
        let sequence = SKKeyframeSequence(capacity: 5)
        sequence.addKeyframeValue(SKColor.white, time: 0)
        sequence.addKeyframeValue(SKColorWithRGB(122, g: 201, b: 67), time: 0.10) //green
        sequence.addKeyframeValue(SKColorWithRGB(0, g: 230, b: 240), time: 0.15) //yellow
        sequence.addKeyframeValue(SKColorWithRGB(255, g: 255, b: 0), time: 0.75) //blue
        sequence.addKeyframeValue(SKColorWithRGB(255, g: 104, b: 0), time: 0.95) //orange
        emitter.particleColorSequence = sequence
        
        
        return emitter
    }
    
    func addTrail(name: String) -> SKEmitterNode {
        let trail = SKEmitterNode(fileNamed: name)!
        trail.zPosition = -1
        trail.position = CGPoint(x: -100, y: 0/*40*/)
        trail.targetNode = fgNode
        player.addChild(trail)
        return trail
    }
    
    func removeTrail(trail: SKEmitterNode) {
        trail.numParticlesToEmit = 1
        trail.run(SKAction.removeFromParentAfterDelay(1.0))
    }
    
    func playBackgroundMusic(name: String) {
        if let backgroundMusic = childNode(withName: "backgroundMusic") {
            backgroundMusic.removeFromParent()
        }
        let music = SKAudioNode(fileNamed: name)
        music.name = "backgroundMusic"
        music.autoplayLooped = true
        addChild(music)
    }
    
    func emitParticles(name: String, sprite: SKSpriteNode) {
        let pos = fgNode.convert(sprite.position, from: sprite.parent!)
        let particles = SKEmitterNode(fileNamed: name)!
        particles.position = pos
        particles.zPosition = 3
        fgNode.addChild(particles)
        particles.run(SKAction.removeFromParentAfterDelay(1.0))
        sprite.run(SKAction.sequence([SKAction.scale(to: 0.0, duration: 0.5), SKAction.removeFromParent()]))
    }
    
    func screenShakeByAmt(_ amt: CGFloat) {
        // 1
        let worldNode = childNode(withName: "World")!
        worldNode.position = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
        worldNode.removeAction(forKey: "shake")
        // 2
        let amount = CGPoint(x: 0, y: -(amt * gameGain))
        // 3
        let action = SKAction.screenShakeWithNode(worldNode, amount: amount, oscillations: 10, duration: 2.0)
        // 4
        worldNode.run(action, withKey: "shake")
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
        
        if breakable == true {
            //emitParticles(name: "BrokenPlatform", sprite: sprite)
        }
    }
    
    func movePlatform(_ sprite: SKSpriteNode, breakable: Bool) {
        let moveVector = CGVector.init(dx: 200, dy: 0)
        let action = SKAction.move(by: moveVector, duration: 4)
        sprite.run(action)
    }
    

    
    /*func addLimitJoint(pos: CGPoint, ropeLength: Int, start: Int) {
        var startPos: Int = 0
        if start == 0 {
            startPos += ropeLength
        } else {
            startPos -= ropeLength
        }
        
        let anchor = SKSpriteNode(imageNamed:"transPixel")
        anchor.position = pos
        anchor.name = "platform_anchor"
        anchor.physicsBody = SKPhysicsBody(circleOfRadius: 1)
        anchor.physicsBody?.affectedByGravity = false
        anchor.physicsBody?.isDynamic = false
        platform.addChild(anchor)
        
        let rope = SKSpriteNode(imageNamed: "transPixel")
        rope.size = CGSize(width: 1, height: ropeLength)
        rope.position = CGPoint(x: anchor.position.x/* + startPos/2*/,y: anchor.position.y)
        rope.physicsBody = SKPhysicsBody(rectangleOf: rope.size)
        rope.physicsBody?.affectedByGravity = false
        rope.physicsBody?.categoryBitMask = 0
        platform.addChild(rope)
        
        let joint = SKPhysicsJointLimit.joint(withBodyA: anchor.physicsBody!, bodyB: player.physicsBody!, anchorA: anchor.position, anchorB: player.position)
        
    }*/
}

// MARK: - Notifications
extension GameScene {
    func applicationDidBecomeActive() {
        print("* applicationDidBecomeActive")
    }
    
    func applicationWillResignActive() {
        print("* applicationWillResignActive")
    }
    
    func applicationDidEnterBackground() {
        print("* applicationDidEnterBackground")
    }
    
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: .UIApplicationDidBecomeActive,
                                       object: nil,
                                       queue: nil) { [weak self] _ in
                                        self?.applicationDidBecomeActive()
        }
        notificationCenter.addObserver(forName: .UIApplicationWillResignActive,
                                       object: nil,
                                       queue: nil) { [weak self] _ in
                                        self?.applicationWillResignActive()
        }
        notificationCenter.addObserver(forName: .UIApplicationWillResignActive,
                                       object: nil,
                                       queue: nil) { [weak self] _ in
                                        self?.applicationDidEnterBackground()
        }
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}
