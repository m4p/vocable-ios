//
//  HeadDirectionTrackingMethod.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit

class HeadDirectionTrackingMethod: TrackingMethod {

    func intersectionLine(faceAnchor: ARFaceAnchor, withHitTestNode hitTestNode: SCNNode) -> LineSegment {
        return LineSegment(start: SCNVector4(0.0, 0.0, 0.0, 1.0), end: SCNVector4(0.0, 0.0, 3.0, 1.0))
    }

    func intersect(faceAnchor: ARFaceAnchor, withHitTestNode hitTestNode: SCNNode) -> SCNHitTestResult? {
        let intersectionLine = self.intersectionLine(faceAnchor: faceAnchor, withHitTestNode: hitTestNode)
        let hits = IntersectionUtils.intersect(lineSegement: intersectionLine, withWorldTransform: faceAnchor.transform, targetNode: hitTestNode)

        return hits.first
    }

}
