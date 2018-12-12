//
//  IntersectionMethod.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit

protocol IntersectionMethod {

    /// Returns the best result, if any, of intersecting a face anchor with a hit test plane.
    ///
    /// The faceAnchor and hitTestPlane must originate from the same scene.
    func intersect(faceAnchor: ARFaceAnchor, withHitTestNode hitTestNode: SCNNode) -> SCNHitTestResult?

}

struct IntersectionResult {
    let hitTest: SCNHitTestResult
    let unitPositionInPlane: CGPoint
}
