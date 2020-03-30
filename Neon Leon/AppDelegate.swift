//
//  AppDelegate.swift
//  Neon Leon
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2017 BD Creative. All rights reserved.
//

import UIKit
import Firebase
import SwiftyStoreKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        NotificationCenter.default.addObserver(self, selector: #selector(backToRootViewController(_:)), name: GameOverScene.mainMenuPressedNotification, object: nil)

        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }

        return true
    }

    @objc
    func backToRootViewController(_ notification: Notification) {
        self.window?.rootViewController?.dismiss(animated: false, completion: nil)
    }
}


