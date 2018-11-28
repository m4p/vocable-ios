//
//  LookAtDirectionTrackingMethod.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit

class LookAtDirectionTrackingMethod: TrackingMethod {

    var buffer: [LineSegment] = []

    func intersectionLine(faceAnchor: ARFaceAnchor, withHitTestNode hitTestNode: SCNNode) -> LineSegment {
        let segment = LineSegment(start: SCNVector4(0.0, 0.0, 0.0, 1.0), end: SCNVector4(faceAnchor.lookAtPoint, w: 0.0))
        buffer.append(segment)
        if (buffer.count > 30) {
            buffer.remove(at: 0)
        }

        let sum = buffer.reduce(simd_float4(0,0,0,0), { result, segment in
            return result + simd_float4(segment.end)
        })

        let averageEnd = 1 / Float(buffer.count) * sum
        let end = simd_float4(
            x: averageEnd.x * (0.5 * averageEnd.z),
            y: averageEnd.y * (0.5 * averageEnd.z),
            z: averageEnd.z,
            w: averageEnd.w
            )
        return LineSegment(start: segment.start, end: SCNVector4(end))
    }

    func intersect(faceAnchor: ARFaceAnchor, withHitTestNode hitTestNode: SCNNode) -> SCNHitTestResult? {
        let intersectionLine = self.intersectionLine(faceAnchor: faceAnchor, withHitTestNode: hitTestNode)
        let hits = IntersectionUtils.intersect(lineSegement: intersectionLine, withWorldTransform: faceAnchor.transform, targetNode: hitTestNode)

        return hits.first
    }

}
