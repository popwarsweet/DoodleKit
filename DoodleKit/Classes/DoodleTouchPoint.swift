//
//  DoodleTouchPoint.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/2/17.
//
//

import Foundation

internal class DoodleTouchPoint: DoodlePath {
    /// The CGPoint where the touch event occurred.
    let cgPoint: CGPoint
    
    /// The timestamp of the touch event, used later to calculate the speed that a variable-width bezier curve was drawn with so that the stroke width can be made thinner or wider accordingly.
    let timestamp: CFAbsoluteTime

    /// The stroke color to use for drawing this as a single-touch-point dot.
    var strokeColor: UIColor = .black
    
    /// The stroke width to use for drawing this as a single-touch-point dot.
    var strokeWidth: CGFloat = 10
    
    /// Calculates the velocity between two points, based on their locations and the time interval between them.
    ///
    /// - Parameter originPoint: The point from which to calculate the velocity of the touch movement.
    /// - Returns: The velocity between the two points
    func velocityFromPoint(_ originPoint: DoodleTouchPoint) -> CGFloat {
        let distance = sqrt(pow((cgPoint.x - originPoint.cgPoint.x), 2) + pow((cgPoint.y - originPoint.cgPoint.y), 2))
        let timeInterval = abs(timestamp - originPoint.timestamp)
        return distance / CGFloat(timeInterval)
    }
    
    
    // MARK: - Init
    
    init(withCgPoint point: CGPoint, timestamp: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()) {
        self.cgPoint = point
        self.timestamp = timestamp
    }
    
    
    // MARK: - DrawablePath
    
    override func draw(inContext context: CGContext) {
        strokeColor.setFill()
        DoodleTouchPoint.drawPoint(cgPoint, withWidth: strokeWidth, inContext: context)
    }
    
    
    // MARK: - Equality
    
    override func equals(_ other: DoodlePath) -> Bool {
        guard let other = other as? DoodleTouchPoint else { return false }
        return self.cgPoint.equalTo(other.cgPoint)
            && self.timestamp == other.timestamp
            && self.strokeColor == other.strokeColor
            && self.strokeWidth == other.strokeWidth
    }
}

extension DoodleTouchPoint {
    static func drawPoint(_ point: CGPoint, withWidth width: CGFloat, inContext context: CGContext) {
        context.fillEllipse(in: CGRect(x: point.x, y: point.y, width: 0, height: 0).insetBy(dx: -width / 2, dy: -width / 2))
    }
}
