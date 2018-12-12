//
//  TrackingConfiguration.swift
//  EyeTrackingTest
//
//  Created by Duncan Lewis on 9/11/18.
//  Copyright © 2018 WillowTree. All rights reserved.
//

import Foundation


struct TrackingConfiguration {

    let intersectionMethod: IntersectionMethod
    let trackingRegion: TrackingRegion
    let trackingType: TrackingType

    init(intersectionMethod: IntersectionMethod, trackingRegion: TrackingRegion, trackingType: TrackingType) {
        self.intersectionMethod = intersectionMethod
        self.trackingRegion = trackingRegion
        self.trackingType = trackingType
    }

    // MARK: - Default Configurations

    static let headTracking: TrackingConfiguration = {
        return TrackingConfiguration(intersectionMethod: HeadDirectionIntersectionMethod(), trackingRegion: RectangleTrackingRegion(width: Constants.phoneScreenSize.width, height: Constants.phoneScreenSize.height), trackingType: .head)
    }()

    static let eyeTracking: TrackingConfiguration = {
        return TrackingConfiguration(intersectionMethod: LookAtDirectionIntersectionMethod(), trackingRegion: RectangleTrackingRegion(width: Constants.phoneScreenSize.width, height: Constants.phoneScreenSize.height), trackingType: .eye)
    }()

}
