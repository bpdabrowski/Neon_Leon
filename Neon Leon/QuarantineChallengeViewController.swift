//
//  QuarantineChallengeViewController.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/30/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import UIKit
import SafariServices

class QuarantineChallengeViewController: UIViewController, SFSafariViewControllerDelegate {

    @IBOutlet private weak var closeButton: UIButton!

    @IBOutlet weak var challengeScore: UILabel!

    @IBOutlet weak var mainImageView: UIImageView!

    var lastGameScore = 0

    var screenShotImage: UIImage?

    var dismissCompletion: (() -> Void)?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        self.challengeScore.text = "Score: \(self.lastGameScore)"
        self.screenShotImage = self.captureScreenshot()
    }

    @IBAction func dismissView(_ sender: UIButton) {
        NotificationCenter.default.post(name: GameOverScene.mainMenuPressedNotification, object: nil)
    }

    func captureScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view!.bounds.size, true, 0)

        self.view!.drawHierarchy(in: self.view!.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return image
    }

    @IBAction func showActivityView(_ sender: Any) {
        let activityController = UIActivityViewController(
            activityItems: [self.screenShotImage],
            applicationActivities: nil
        )
        activityController.excludedActivityTypes = [.print,
                                                    .addToReadingList,
                                                    .postToVimeo,
                                                    .assignToContact,
                                                    .copyToPasteboard,
                                                    .openInIBooks,
                                                    .print]

        self.present(activityController, animated: true, completion: nil)
    }

    @available(iOS 11.0, *)
    @IBAction func showDonationView(_ sender: UIButton) {
        if let donationUrl = URL(string: "https://give.cdcfoundation.org") {
            let safariViewController = SFSafariViewController(url: donationUrl, configuration: SFSafariViewController.Configuration())
            safariViewController.delegate = self
            present(safariViewController, animated: true)
        }
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.mainImageView.image = UIImage(imageLiteralResourceName: "DonationImage")
        self.screenShotImage = self.captureScreenshot()

        let alert = UIAlertController(title: "Tell Everyone You Donated!",
                                      message: "Would you like to share this 'I Donated' picture to encourage more people to donate and help our fight with COVID-19?",
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Yes 😃", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            self.showActivityView(self)
        })
        alert.addAction(UIAlertAction(title: "No 🙁", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}
