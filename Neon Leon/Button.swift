//
//  RestartButton.swift
//  KittyJump
//
//  Created by BDabrowski on 5/20/17.
//  Copyright © 2017 Broski Studios. All rights reserved.
//

import Foundation
import SpriteKit

class Button: SKNode {
    let defaultButton: SKSpriteNode
    let activeButton: SKSpriteNode
    var action: () -> ()
    let pressSound = SKAction.playSoundFileNamed("Button Press.wav", waitForCompletion: false)
    
    let notification = UINotificationFeedbackGenerator()
    
    init(defaultButtonImage: String, activeButtonImage: String, buttonAction: @escaping () -> ()) {
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        activeButton.isHidden = true
        action = buttonAction
        
        super.init()
        
        isUserInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeButton.isHidden = false
        defaultButton.isHidden = true
        notification.notificationOccurred(.success)
        run(pressSound)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if defaultButton.contains(location) {
                activeButton.isHidden = false
                defaultButton.isHidden = true
            } else {
                activeButton.isHidden = true
                defaultButton.isHidden = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if defaultButton.contains(location) {
                action()
            }
            
            activeButton.isHidden = true
            defaultButton.isHidden = false
        }
    }
}

/*class RestartButton: SKSpriteNode, EventListenerNode, InteractiveNode {
    
    let gameScene = GameScene()
    
    convenience init(imageNamed image: String) {
        super.init(imageNamed: image)
        //self.position = position
        //let iconScale = SKAction.scale(to: 1.5, duration: 0.2)
        position = gameScene.camera!.position + CGPoint(x: 0, y: -750)
        zPosition = 10
        setScale(1)
        //addChild(sprite)
        //run(SKAction.sequence([SKAction.wait(forDuration: 0.2), iconScale]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    
    //let clown = SKSpriteNode(imageNamed: "Clown")
    
    func didMoveToScene() {
        print("Restart Button added to scene")
        
        isUserInteractionEnabled = true
    }
    
    func interact() {
        print("interact() called")
        
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        interact()
    }
}*/
