//
//  SocialShareViewController.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/27/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import UIKit

class SocialShareViewController: UIViewController {

    @IBOutlet private weak var shareButton: UIButton!

    @IBOutlet private weak var closeButton: UIButton!

    @IBOutlet private weak var challengeScore: UILabel!

    var highScore = 0

    var congratsImage: UIImage?

    var dismissCompletion: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.challengeScore.text = "Score: \(self.highScore)"
        self.congratsImage = self.captureScreenshot()
    }

    @IBAction func showActivityView(_ sender: Any) {
        let activityController = UIActivityViewController(
            activityItems: [self.congratsImage],
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


    @IBAction func dismissView(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.dismissCompletion?()
        }
    }

    func captureScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view!.bounds.size, true, 0)

        self.view!.drawHierarchy(in: self.view!.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        return image
    }

}
