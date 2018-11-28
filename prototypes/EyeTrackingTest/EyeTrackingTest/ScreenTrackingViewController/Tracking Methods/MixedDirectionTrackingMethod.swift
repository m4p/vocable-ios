//
//  MixedDirectionTrackingMethod.swift
//  EyeTrackingTest
//
//  Created by Joel Garrett on 11/21/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit

class MixedDirectionTrackingMethod: TrackingMethod {

    private let headDirectionTrackingMethod: HeadDirectionTrackingMethod
    private let lookAtDirectionTrackingMethod: LookAtDirectionTrackingMethod

    init() {
        self.headDirectionTrackingMethod = HeadDirectionTrackingMethod()
        self.lookAtDirectionTrackingMethod = LookAtDirectionTrackingMethod()
    }

    func intersectionLine(faceAnchor: ARFaceAnchor, withHitTestNode hitTestNode: SCNNode) -> LineSegment {
        let headIntersectionLine = self.headDirectionTrackingMethod.intersectionLine(faceAnchor: faceAnchor, withHitTestNode: hitTestNode)
        let lookIntersectionLine = self.lookAtDirectionTrackingMethod.intersectionLine(faceAnchor: faceAnchor, withHitTestNode: hitTestNode)
        // Mix the lines

        let start = SCNVector4((simd_float4(headIntersectionLine.start) + simd_float4(lookIntersectionLine.start)) * 0.5)
        let end = SCNVector4((simd_float4(headIntersectionLine.end) + (simd_float4(lookIntersectionLine.end) * 500.0)) * 0.5)

        return LineSegment(start: start, end: end)
    }

    func intersect(faceAnchor: ARFaceAnchor, withHitTestNode hitTestNode: SCNNode) -> SCNHitTestResult? {
        let intersectionLine = self.intersectionLine(faceAnchor: faceAnchor, withHitTestNode: hitTestNode)
        let hits = IntersectionUtils.intersect(lineSegement: intersectionLine, withWorldTransform: faceAnchor.transform, targetNode: hitTestNode)

        return hits.first
    }

}
