//
//  LostChallengeViewController.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/30/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import UIKit

class LostChallengeViewController: QuarantineChallengeViewController {

    @IBOutlet private weak var tryAgainButton: UIButton!

    var tryAgainButtonAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tryAgainTapped(_ sender: UIButton) {
        self.dismiss(animated: true) { [weak self] in
            self?.tryAgainButtonAction?()
        }
    }

}
