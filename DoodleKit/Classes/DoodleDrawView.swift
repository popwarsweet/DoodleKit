//
//  DoodleDrawView.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/5/17.
//
//

import UIKit

class DoodleDrawView: UIView {
    // Constants
    static let velocityFilterWeight: CGFloat = 0.9
    static let initialVelocity: CGFloat = 220
    static let relativeMinStrokeWidth: CGFloat = 0.4
    
    // Properties
    
    /// Sets the stroke width if constantStrokeWidth is true, or sets the base strokeWidth for variable drawing paths.
    ///
    /// - Note: Set drawingStrokeWidth in DoodleViewController to control this setting.
    var strokeWidth: CGFloat = 10
    
    /// Sets the stroke color. Each path can have its own stroke color.
    var strokeColor: UIColor = .black {
        didSet { updateStrokeColor(strokeColor) }
    }
    
    /// Set to YES if you want the stroke width to be constant, NO if the stroke width should vary depending on drawing speed.
    var isStrokeWidthConstant: Bool = false {
        didSet { updateIsStrokeWidthConstant(isStrokeWidthConstant) }
    }
    
    /// Image representing paths in the `pathArray` that have been drawn to a static image.
    fileprivate var cachedDrawnPathsImage: UIImage?
    
    /// Paths representing the user touches.
    fileprivate var paths = [DoodlePath]()
    
    /// The array capturing paths from the current touch down to touch up event.
    fileprivate var currentStrokes = [DoodlePath]()

    /// The array containing paths from each touch down to touch up event.
    fileprivate var allStrokes = [[DoodlePath]]()

    /// Bezier path created from items in `points` array.
    fileprivate var currentBezierPath: DoodleTouchBezier?
    
    /// The points captured during touch down & moved events.
    fileprivate var points = [DoodleTouchPoint]()
    
    /// Counter used to determine when to create bezier path from items in `points` array.
    fileprivate var pointsCounter = 0
    
    fileprivate var initialVelocity: CGFloat = DoodleDrawView.initialVelocity
    fileprivate var lastVelocity: CGFloat = DoodleDrawView.initialVelocity
    fileprivate var lastWidth: CGFloat = 10
    
    
    // MARK: - Init
    
    private func commonInit() {
        // All interactions will be forward to this view through the container.
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    // MARK: - Undo
    
    func undoLastStroke() {
        guard allStrokes.count > 0 else { return }
        
        // Remove paths for stroke.
        let lastStrokePaths = allStrokes.removeLast()
        paths = paths.filter { !lastStrokePaths.contains($0) }
        
        // Reset state.
        currentBezierPath = nil
        pointsCounter = 0
        points = []
        lastVelocity = initialVelocity
        lastWidth = strokeWidth
        
        // Redraw
        drawBitmapIgnoringCache()
    }

    func clearDrawing() {
        // Reset state.
        cachedDrawnPathsImage = nil
        paths = []
        currentBezierPath = nil
        pointsCounter = 0
        points = []
        lastVelocity = initialVelocity
        lastWidth = strokeWidth
        
        // Animate.
        UIView.transition(with: self,
                          duration: 0.2,
                          options: [.transitionCrossDissolve],
                          animations: { self.setNeedsDisplay() },
                          completion: nil)
    }
    
    
    // MARK: - Property updates
    
    fileprivate func updateIsStrokeWidthConstant(_ isConstant: Bool) {
        isStrokeWidthConstant = isConstant
        currentBezierPath = nil
        points = []
        pointsCounter = 0
    }
    
    fileprivate func updateStrokeColor(_ strokeColor: UIColor) {
        currentBezierPath = nil
    }
    
    
    // MARK: - Touch handling
    
    func drawTouchBegan(at point: CGPoint) {
        lastVelocity = initialVelocity
        lastWidth = strokeWidth
        pointsCounter = 0
        currentStrokes = []
        
        let touchPoint = DoodleTouchPoint(withCgPoint: point)
        points = [touchPoint]
    }
    
    func drawTouchPointMoved(to point: CGPoint) {
        pointsCounter += 1
        points.append(DoodleTouchPoint(withCgPoint: point))
        
        if pointsCounter == 4 {
            let bezierEndPoint = CGPoint(x: (points[2].cgPoint.x + points[4].cgPoint.x) / 2,
                                         y: (points[2].cgPoint.y + points[4].cgPoint.y) / 2)
            let touchBezierEndPoint = DoodleTouchPoint(withCgPoint: bezierEndPoint)
            points[3] = touchBezierEndPoint
            
            let bezierPath = DoodleTouchBezier(timestamp: CFAbsoluteTimeGetCurrent())
            bezierPath.strokeColor = strokeColor
            bezierPath.startPoint = points[0].cgPoint
            bezierPath.endPoint = points[3].cgPoint
            bezierPath.controlPoint1 = points[1].cgPoint
            bezierPath.controlPoint2 = points[2].cgPoint
            
            if isStrokeWidthConstant {
                bezierPath.startWidth = strokeWidth
                bezierPath.endWidth = strokeWidth
            } else {
                var velocity = points[3].velocityFromPoint(points[0])
                velocity = (DoodleDrawView.velocityFilterWeight * velocity) + ((1 - DoodleDrawView.velocityFilterWeight) * lastVelocity)
                
                let strokeWidth = strokeWidthForVelocity(velocity)
                
                bezierPath.startWidth = lastWidth
                bezierPath.endWidth = strokeWidth
                
                lastWidth = strokeWidth
                lastVelocity = velocity
            }
            
            currentStrokes.append(bezierPath)
            currentBezierPath = bezierPath
            paths.append(bezierPath)
            
            points[0] = points[3]
            points[1] = points[4]
            
            drawBitmap()
            
            points.removeLast()
            points.removeLast()
            points.removeLast()
            pointsCounter = 1
        }
    }
    
    func drawTouchEnded() {
        drawBitmap()
        
        lastVelocity = initialVelocity
        lastWidth = strokeWidth
        
        allStrokes.append(currentStrokes)
        currentStrokes = []
    }
    
    
    // MARK: - Drawing
    
    fileprivate func drawBitmapIgnoringCache() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        drawAllPaths()
        
        currentBezierPath?.draw(inContext: context)
        currentBezierPath = nil
        
        if points.count == 1, let touchPoint = points.first {
            touchPoint.strokeColor = strokeColor
            touchPoint.strokeWidth = 1.5 * strokeWidthForVelocity(1)
            paths.append(touchPoint)
            currentStrokes.append(touchPoint)
            touchPoint.strokeColor.setFill()
            DoodleTouchPoint.drawPoint(touchPoint.cgPoint,
                                       withWidth: touchPoint.strokeWidth,
                                       inContext: context)
        }
        
        cachedDrawnPathsImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setNeedsDisplay()
    }

    fileprivate func drawBitmap() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        cachedDrawnPathsImage?.draw(at: .zero)
        currentBezierPath?.draw(inContext: context)
        currentBezierPath = nil
        
        if points.count == 1, let touchPoint = points.first {
            touchPoint.strokeColor = strokeColor
            touchPoint.strokeWidth = 1.5 * strokeWidthForVelocity(1)
            paths.append(touchPoint)
            currentStrokes.append(touchPoint)
            if let context = UIGraphicsGetCurrentContext() {
                touchPoint.draw(inContext: context)
            }
        }
        
        cachedDrawnPathsImage =  UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        cachedDrawnPathsImage?.draw(in: rect)
        if let context = UIGraphicsGetCurrentContext() {
            currentBezierPath?.draw(inContext: context)
        }
    }
    
    
    // MARK: - Helpers
    
    fileprivate func strokeWidthForVelocity(_ velocity: CGFloat) -> CGFloat {
        return strokeWidth - ((strokeWidth * (1 - DoodleDrawView.relativeMinStrokeWidth)) / (1 + pow(CGFloat(M_E), (-((velocity - initialVelocity) / initialVelocity)))))
    }
    
    
    // MARK: - Image rendering

    fileprivate func renderedDrawing(withSize size: CGSize) -> UIImage? {
        return drawAllPathsOnImage(nil, size: size)
    }
    
    fileprivate func drawAllPaths() {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        paths.forEach { $0.draw(inContext: context) }
    }
    
    fileprivate func drawAllPathsOnImage(_ image: UIImage?, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image?.draw(in: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        drawAllPaths()
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func renderedDrawing(onImage image: UIImage? = nil, size: CGSize) -> UIImage? {
        return drawAllPathsOnImage(image, size: size)
    }
}
