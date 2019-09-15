//
//  CoreGraphics+Utilities.swift
//  EyeSpeak
//
//  Created by Kyle Ohanian on 5/15/19.
//  Copyright © 2019 WillowTree. All rights reserved.
//

import UIKit

extension CGPoint {
    init(value: CGFloat) {
        self.init(x: value, y: value)
    }
    
    init(value: Int) {
        self.init(x: value, y: value)
    }
    
    init(value: Double) {
        self.init(x: value, y: value)
    }
    
    func multiply(by value: CGFloat) -> CGPoint {
        return CGPoint(x: self.x * value, y: self.y * value)
    }

    func distance(from secondPoint: CGPoint) -> CGFloat {
        return sqrt(pow(secondPoint.x - x, 2) + pow(secondPoint.y - y, 2))
    }
}

extension CGSize {
    init(value: CGFloat) {
        self.init(width: value, height: value)
    }
    
    init(value: Int) {
        self.init(width: value, height: value)
    }
    
    init(value: Double) {
        self.init(width: value, height: value)
    }
    
    func multiply(by value: CGFloat) -> CGSize {
        return CGSize(width: self.width * value, height: self.height * value)
    }
}
