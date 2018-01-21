//
//  GameViewController.swift
//  DropCharge
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2017 Broski Studios. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase
import GoogleMobileAds
import AVFoundation

extension Notification.Name {
    static let showAd = Notification.Name(rawValue: "NotificationShowAd")
}

var backgroundMusicPlayer: AVAudioPlayer?

class GameViewController: UIViewController, GADBannerViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SwiftyAd.shared.showBanner(from: self)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
            }
            
            let path = Bundle.main.path(forResource: "Spacebased_Full.mp3", ofType: nil)!
            let url = URL(fileURLWithPath: path)
            
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.play()
            } catch {
                // couldn't load file
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
        print("******** MEMORY WARNING!")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
