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
