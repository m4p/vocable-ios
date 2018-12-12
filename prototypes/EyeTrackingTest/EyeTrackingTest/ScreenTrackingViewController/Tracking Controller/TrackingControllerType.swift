//
//  TrackingControllerType.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 11/28/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import Foundation
import ARKit

protocol TrackingControllerType {

    var trackingNode: SCNNode { get }
    func processFaceAnchor(_ faceAnchor: ARFaceAnchor)

}
