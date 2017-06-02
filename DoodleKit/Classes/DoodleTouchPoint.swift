//
//  DoodleTouchPoint.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/2/17.
//
//

import Foundation

internal struct DoodleTouchPoint {
    /**
     *  The CGPoint where the touch event occurred.
     */
    let point: CGPoint
    
    /**
     *  The timestamp of the touch event, used later to calculate the
     *  speed that a variable-width bezier curve was drawn with so that
     *  the stroke width can be made thinner or wider accordingly.
     */
    let timestamp: Date

    /**
     *  The stroke color to use for drawing this as a single-touch-point dot.
     */
    let strokeColor: UIColor

    /**
     *  The stroke width to use for drawing this as a single-touch-point dot.
     */
    let strokeWidth: CGFloat

    /**
     *  Calculates the velocity between two points, based on their locations
     *  and the time interval between them.
     *
     *  parameter point The point from which to calculate the velocity of the touch movement.
     *
     *  returns The velocity between the two points
     */
    func velocityFromPoint(_ originPoint: DoodleTouchPoint) -> CGFloat {
        let distance = sqrt(pow((point.x - originPoint.point.x), 2) + pow((point.y - originPoint.point.y), 2))
        let timeInterval = abs(self.timestamp.timeIntervalSince(originPoint.timestamp))
        return distance / CGFloat(timeInterval)
    }
}
