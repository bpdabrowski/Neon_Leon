//
//  GameViewController.swift
//  Neon Leion
//
//  Created by BDabrowski on 4/16/17.
//  Copyright © 2018 BD Creative. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Firebase
import AVFoundation
import SwiftyStoreKit
import StoreKit
import FBAudienceNetwork

// within iTunes Connect > go to in app purchases > on the right select View shared secret > copy that and paste in quotes below
var sharedSecret = "30ca8d6c6cde4e7cb26fb382db93f14a"

enum RegisteredPurchase: String {
    case RemoveAds = "RemoveAds"
    case purchase1
    case purchase2
    case nonConsumablePurchase
    case consumablePurchase
    case nonRenewingPurchase
    case autoRenewableWeekly
    case autoRenewableMonthly
    case autoRenewableYearly
}

class NetworkActivityIndicatorManager: NSObject {
    
    private static var loadingCount = 0
    
    class func NetworkOperationStarted() {
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    
    class func NetworkOperationFinished() {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
}

extension Notification.Name {
    static let showAd = Notification.Name(rawValue: "NotificationShowAd")
}

var backgroundMusicPlayer: AVAudioPlayer?

class GameViewController: UIViewController, FBAdViewDelegate {
    
    var removeAdsPurchased = false

    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    
    let bundleID = "com.BDCreative.NeonLeion"
    
    var RemoveAds = RegisteredPurchase.RemoveAds
    
    var soundOff = false

    var adContainer: UIView!

    var adView: FBAdView?

    var highScore = 0
    
    func removeAds() {
        print("removeAds is getting called")
        purchase(RemoveAds, atomically: true)
    }
    
    override func loadView() {
        self.view = SKView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        restorePurchases()

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

//        if nonConsumablePurchaseMade == true {
//            SwiftyAd.shared.isRemoved = true
//            print("NON CONSUMABLE PURCHASE MADE: \(nonConsumablePurchaseMade)")
//        } else {
//            SwiftyAd.shared.isRemoved = false
//            SwiftyAd.shared.showBanner(from: self)
//        }
        
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
            
            if soundOff == true {
                //change button to a sound with an x in it.
            } else if soundOff == false {
                do {
                    backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                    backgroundMusicPlayer?.numberOfLoops = -1
                    backgroundMusicPlayer?.prepareToPlay()
                    backgroundMusicPlayer?.play()
                } catch {
                    // couldn't load file
                }
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    func adView(_ adView: FBAdView, didFailWithError: Error) {
        print("Ad failed to load \(didFailWithError)")
    }

    func adViewDidLoad(_ adView: FBAdView) {
        print("Ad was loaded and ready to display")

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
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func getInfo(purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([bundleID + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
            
            self.showAlert(alert: self.alertForProductRetrievalInfo(result: result))
            
        }
    }
    
    func purchase(_ purchase: RegisteredPurchase, atomically: Bool) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct(bundleID + "." + purchase.rawValue, atomically: atomically) { result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
            
            if case .success(let product) = result {
                
                if product.productId == self.bundleID + "." + "RemoveAds" {
                    self.removeAdsPurchased = true
                    if self.removeAdsPurchased == true {
//                        SwiftyAd.shared.isRemoved = true
                        self.nonConsumablePurchaseMade = true
                        UserDefaults.standard.set(self.nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
                    } else {
//                        SwiftyAd.shared.isRemoved = false
                    }
                }
                
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
                if let alert = self.alertForPurchaseResult(result) {
                    self.showAlert(alert: alert)
                }
            }
            
        }
    }
    
    func restorePurchases() {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
//                SwiftyAd.shared.isRemoved = true
                self.nonConsumablePurchaseMade = true
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
            
            print("skipped everything and just showing alert")
    
            //self.showAlert(alert: self.alertForRestorePurchases(result: results))
                
            
        }
    }
    
    func restorePurchasesWithAlert() {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
//                SwiftyAd.shared.isRemoved = true
                self.nonConsumablePurchaseMade = true
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
            
            print("skipped everything and just showing alert")
            
            self.showAlert(alert: self.alertForRestorePurchases(result: results))
        }
    }
    
    func verifyReceipt() {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
            
            self.showAlert(alert: self.alertForVerifyReceipt(result: result))
        }
    }
    
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }
    
    func verifyPurchase(_ purchase: RegisteredPurchase) {
            NetworkActivityIndicatorManager.NetworkOperationStarted()
            verifyReceipt { result in
                NetworkActivityIndicatorManager.NetworkOperationFinished()
                
                switch result {
                case .success(let receipt):
                    
                    let productId = self.bundleID + "." + purchase.rawValue
                
                switch purchase {
                case .autoRenewableWeekly, .autoRenewableMonthly, .autoRenewableYearly:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productId,
                        inReceipt: receipt)
                    self.showAlert(alert: self.alertForVerifySubscription(result: purchaseResult))
                case .nonRenewingPurchase:
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .nonRenewing(validDuration: 60),
                        productId: productId,
                        inReceipt: receipt)
                    self.showAlert(alert: self.alertForVerifySubscription(result: purchaseResult))
                default:
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(
                        productId: productId,
                        inReceipt: receipt)
                    self.showAlert(alert: self.alertForVerifyPurchase(result: purchaseResult))
                }
                
                case .error:
                    self.showAlert(alert: self.alertForVerifyReceipt(result: result))
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let socialShareViewController = segue.destination as? SocialShareViewController {
            socialShareViewController.highScore = self.highScore
            socialShareViewController.dismissCompletion = {
                let alert = UIAlertController(title: "Share Challenge With Everyone!",
                                              message: "We have also saved a screenshot of the challenge to your photos. Please share to all your social networks to encourage people to donate to the CDC Foundation.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Open Photos", style: .default) { _ in
                    guard let photosUrl = URL(string:"photos-redirect://") else {
                        return
                    }
                    UIApplication.shared.open(photosUrl)
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension GameViewController {

    func alertWithTitle(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(alert: UIAlertController) {
        guard let _ = self.presentedViewController else {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    func alertForProductRetrievalInfo(result: RetrieveResults) -> UIAlertController {
        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            return alertWithTitle(title: product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
        }
        else if let invalidProductID = result.invalidProductIDs.first {
            return alertWithTitle(title: "Could not retried product info", message: "Invalid product identifier: \(invalidProductID)")
        }
        else {
            let errorString = result.error?.localizedDescription ?? "Unknown Error. Please contact support."
            return alertWithTitle(title: "Could not retreive product info", message: errorString)
        }
    }
    
    
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return nil
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle(title: "Purchase failed", message: error.localizedDescription)
            case .clientInvalid:
                return alertWithTitle(title: "Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled:
                return nil
            case .paymentInvalid:
                return alertWithTitle(title: "Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed:
                return alertWithTitle(title: "Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable:
                return alertWithTitle(title: "Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied:
                return alertWithTitle(title: "Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed:
                return alertWithTitle(title: "Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked:
                return alertWithTitle(title: "Purchase failed", message: "Cloud service was revoked")
            case .privacyAcknowledgementRequired,
                 .unauthorizedRequestData,
                 .invalidOfferIdentifier,
                 .invalidSignature,
                 .missingOfferParams,
                 .invalidOfferPrice:
                return alertWithTitle(title: "Purchase failed", message: "Please contact support. Sorry for the inconvenience.")
            }
        }
    }
    
    func alertForRestorePurchases(result: RestoreResults) -> UIAlertController {
        if result.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(result.restoreFailedPurchases)")
            return alertWithTitle(title: "Restore Failed", message: "Unknown Error. Please Contact Support.")
        }
        else if result.restoredPurchases.count > 0 {
            return alertWithTitle(title: "Purchases Restored", message: "All purchases have been restored.")
        }
        else {
            return alertWithTitle(title: "Nothing To Restore", message: "No previous purchases were made.")
        }
    }
    
    func alertForVerifyReceipt(result: VerifyReceiptResult) -> UIAlertController {
        switch result {
        case .success:
            return alertWithTitle(title: "Receipt Verified", message: "Receipt Verified Remotely")
        case .error(let error):
            switch error {
            case .noReceiptData:
                return alertWithTitle(title: "Receipt Verfication", message: "No receipt data found, application will try to get a new one. Try Again.")
            default:
                return alertWithTitle(title: "Receipt Verification", message: "Receipt Verification Failed.")
            }
        }
    }
    
    func alertForVerifySubscription(result: VerifySubscriptionResult) -> UIAlertController {
        switch result {
        case .purchased(let expiryDate):
            return alertWithTitle(title: "Product is Purchased", message: "Product will be valid until \(expiryDate).")
        case .notPurchased:
            return alertWithTitle(title: "Not Purchased", message: "This product has never been purchased.")
        case .expired(let expiryDate):
            return alertWithTitle(title: "Product Expired", message: "Product is expired since \(expiryDate).")
        }
    }
    
    func alertForVerifyPurchase(result: VerifyPurchaseResult) -> UIAlertController {
        switch result {
        case .purchased:
            return alertWithTitle(title: "Product is Purchased", message: "Product will not expire.")
        case .notPurchased:
            return alertWithTitle(title: "Product Not Purchased", message: "Product has never been purchased.")
        }
    }
}
