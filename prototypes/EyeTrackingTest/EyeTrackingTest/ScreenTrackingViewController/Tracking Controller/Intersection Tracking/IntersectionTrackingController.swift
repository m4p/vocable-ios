//
//  TrackingNode.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/14/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import ARKit

protocol IntersectionTrackingControllerDelegate: class {
    func intersectionTrackingController(_ controller: IntersectionTrackingController, didUpdateTrackedPositionOnScreen: CGPoint?)
}

class IntersectionTrackingController: TrackingControllerType {

    weak var delegate: IntersectionTrackingControllerDelegate?

    // MARK: - TrackingControllerType

    var trackingNode: SCNNode

    func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        guard let hitTest = intersectionMethod.intersect(faceAnchor: faceAnchor, withHitTestNode: self.trackingNode) else {
            return
        }

        guard let unitPosition = trackingRegion.unitPosition(for: hitTest) else {
            return
        }

        let intersectionResult = IntersectionResult(hitTest: hitTest, unitPositionInPlane: unitPosition)

        self.reportIntersectionToDelegate(intersectionResult)
    }

    private func reportIntersectionToDelegate(_ trackingResult: IntersectionResult?) {
        DispatchQueue.main.async {
            if let trackingResult = trackingResult {
                let screenPosition = IntersectionUtils.screenPosition(fromUnitPosition: trackingResult.unitPositionInPlane)
                self.delegate?.intersectionTrackingController(self, didUpdateTrackedPositionOnScreen: screenPosition)
            } else {
                self.delegate?.intersectionTrackingController(self, didUpdateTrackedPositionOnScreen: nil)
            }
        }
    }

    // MARK: - Configuration

    var trackingConfiguration: TrackingConfiguration

    private var intersectionMethod: IntersectionMethod { return self.trackingConfiguration.intersectionMethod }
    private var trackingRegion: TrackingRegion { return self.trackingConfiguration.trackingRegion }


    // MARK: -

    init(trackingConfiguration config: TrackingConfiguration) {
        self.trackingConfiguration = config
        self.trackingNode = SCNNode()

        self.intersectionNode.geometry = self.hitTestPlane
        self.trackingNode.addChildNode(self.intersectionNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }


    // MARK: - Node

    private let intersectionNode = SCNNode()

    private let hitTestPlane: SCNPlane = {
        let plane = SCNPlane(width: 100.0, height: 100.0) // psuedo-infinite plane
        plane.materials.first?.diffuse.contents = UIColor.white
        plane.materials.first?.transparency = 0.3
        plane.materials.first?.isDoubleSided = true
        return plane
    }()

}
