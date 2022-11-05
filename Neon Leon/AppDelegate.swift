//
//  AppDelegate.swift
//  Neon Leon
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2017 BD Creative. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(backToRootViewController(_:)),
                                               name: GameOverScene.mainMenuPressedNotification,
                                               object: nil)

        return true
    }

    @objc
    func backToRootViewController(_ notification: Notification) {
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
}


