//
//  NetworkActivityIndicatorManager.swift
//  Neon Leon
//
//  Created by Dabrowski,Brendyn on 3/28/20.
//  Copyright © 2020 BD Creative. All rights reserved.
//

import UIKit

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
