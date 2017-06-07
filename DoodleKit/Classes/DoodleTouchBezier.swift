//
//  DoodleTouchBezier.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/2/17.
//
//

import Foundation

internal class DoodleTouchBezier: DoodlePath {
    fileprivate static let drawStepsPerBezier = 300
    
    /// Start time of first point of bezier path.
    var timestamp: CFAbsoluteTime
    
    /// The start point of the cubic bezier path.
    var startPoint: CGPoint = .zero
    
    /// The end point of the cubic bezier path.
    var endPoint: CGPoint = .zero
    
    /// The first control point of the cubic bezier path.
    var controlPoint1: CGPoint = .zero
    
    /// The second control point of the cubic bezier path.
    var controlPoint2: CGPoint = .zero
    
    /// The starting width of the cubic bezier path.
    var startWidth: CGFloat = 10
    
    /// The ending width of the cubic bezier path.
    var endWidth:  CGFloat = 10
    
    /// The stroke color of the cubic bezier path.
    var strokeColor: UIColor = .black
    
    /// YES if the line is a constant width, NO if variable width.
    var isConstantWidth = false
    
    
    // MARK: - Init
    
    init(timestamp: CFAbsoluteTime) {
        self.timestamp = timestamp
    }
    
    
    // MARK: - DrawablePath
    
    override func draw(inContext context: CGContext) {
        if isConstantWidth {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: startPoint)
            bezierPath.addCurve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            bezierPath.lineWidth = startWidth
            bezierPath.lineCapStyle = .round
            strokeColor.setStroke()
            bezierPath.stroke(with: .normal, alpha: 1)
        } else {
            strokeColor.setFill()
            
            let widthDelta = endWidth - startWidth
            
            for i in 0..<DoodleTouchBezier.drawStepsPerBezier {
                let t = CGFloat(i) / CGFloat(DoodleTouchBezier.drawStepsPerBezier)
                let tt = t * t
                let ttt = tt * t
                let u = 1 - t
                let uu = u * u
                let uuu = uu * u
                
                var x = uuu * startPoint.x
                x += 3 * uu * t * controlPoint1.x
                x += 3 * u * tt * controlPoint2.x
                x += ttt * endPoint.x
                
                var y = uuu * startPoint.y
                y += 3 * uu * t * controlPoint1.y
                y += 3 * u * tt * controlPoint2.y
                y += ttt * endPoint.y
                
                let pointWidth = startWidth + (ttt * widthDelta)
                DoodleTouchPoint.drawPoint(CGPoint(x: x, y: y), withWidth: pointWidth, inContext: context)
            }
        }
    }
    
    
    // MARK: - Equality
    
    override func equals(_ other: DoodlePath) -> Bool {
        guard let other = other as? DoodleTouchBezier else { return false }
        return self.timestamp == other.timestamp
            && self.startPoint == other.startPoint
            && self.endPoint == other.endPoint
            && self.controlPoint1 == other.controlPoint1
            && self.controlPoint2 == other.controlPoint2
            && self.startWidth == other.startWidth
            && self.endWidth == other.endWidth
            && self.strokeColor == other.strokeColor
            && self.isConstantWidth == other.isConstantWidth
    }
}
