//
//  NeonLeonViewController.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/28/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import FBAudienceNetwork
import SpriteKit
import UIKit

class NeonLeonViewController: UIViewController, FBAdViewDelegate {

    @IBOutlet var spriteKitView: SKView!

    var adContainer: UIView!

    var adView: FBAdView?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAdView()
    }

    private func setupAdView() {
        self.adContainer = UIView()
        self.view.addSubview(self.adContainer)

        self.adContainer.translatesAutoresizingMaskIntoConstraints = false
        self.adContainer.widthAnchor.constraint(equalToConstant: 320).isActive = true
        self.adContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.adContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.adContainer.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        self.adView = FBAdView(placementID: "522128718497279_522129065163911", adSize: kFBAdSizeHeight50Banner, rootViewController: self)
        self.adView?.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        self.adView?.delegate = self
        self.adView?.loadAd()
    }

    func adView(_ adView: FBAdView, didFailWithError: Error) {
        print("Ad failed to load \(didFailWithError)")
    }

    func adViewDidLoad(_ adView: FBAdView) {
        guard let adContainer = self.adContainer else {
            print("Ad Container is nil")
            return
        }

        guard let adView = self.adView, adView.isAdValid else {
            print("Ad view is either nil or is not valid.")
            return
        }

        adContainer.addSubview(adView)
    }
}
