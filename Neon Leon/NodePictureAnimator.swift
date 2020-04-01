//
//  NodePictureAnimator.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/29/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import SpriteKit

class NodePictureAnimator {

    func setupButton(pictureBase: String,
                     pictureWidth: Int,
                     pictureHeight: Int,
                     buttonPositionX: Int,
                     buttonPositionY: Int,
                     zPosition: CGFloat) -> SKSpriteNode {

        let button = SKSpriteNode(imageNamed: pictureBase)
        button.size = CGSize(width: pictureWidth, height: pictureHeight)
        button.position = CGPoint(x: buttonPositionX, y:buttonPositionY)
        button.zPosition = zPosition

        return button
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

    func setupAnimationWithPrefix(_ prefix: String, start: Int, end: Int, timePerFrame: TimeInterval) -> SKAction {
        var textures = [SKTexture]()
        for i in start...end {
            textures.append(SKTexture(imageNamed: "\(prefix)\(i)"))
        }
        return SKAction.animate(with: textures, timePerFrame: timePerFrame)
    }
}
