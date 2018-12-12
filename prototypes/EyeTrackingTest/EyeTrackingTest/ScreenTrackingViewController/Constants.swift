//
//  Constants.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/11/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import UIKit


struct Constants {

    static var physicalScreenSize: CGSize {
        switch UIDevice.current.type {
        case .iPadPro3_11:
            return CGSize(width: 0.1785, height: 0.2476)
        case .iPadPro3_12_9:
            return CGSize(width: 0.2149, height: 0.2806)
        case .iPhoneX, .iPhoneXR, .iPhoneXS, .iPhoneXSmax:
            // haven't specified other sizes besides iPhoneX
            return CGSize(width: 0.0623908297, height: 0.135096943231532)
        default:
            // fallback to iphoneX size
            return CGSize(width: 0.0623908297, height: 0.135096943231532)
        }
    }

}
