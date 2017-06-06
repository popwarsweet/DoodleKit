//
//  DoodleTextView.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/5/17.
//
//

import UIKit

internal class DoodleTextView: UIView {
    
    /// The label used for displaying text.
    fileprivate(set) lazy var textLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.textAlignment = .center
        label.font = self.font
        label.textColor = .white
        label.center = CGPoint(x: UIScreen.main.bounds.midX,
                               y: UIScreen.main.bounds.midY)
        return label
    }()
    
    /// The text string the DoodleTextView is currently displaying.
    ///
    /// - Note: Set textString in DoodleViewController to control or read this property.
    var textString: String? {
        set {
            let center = textLabel.center
            textLabel.text = newValue
            sizeLabel()
            textLabel.center = center
        }
        get { return textLabel.text }
    }
    
    /// The color of the text displayed in the DoodleTextView.
    ///
    /// - Note: Set textColor in DoodleViewController to control this property.
    var textColor: UIColor {
        set { textLabel.textColor = newValue }
        get { return textLabel.textColor }
    }
    
    /// The font of the text displayed in the DoodleTextView.
    ///
    /// - Note: Set font in DoodleViewController to control this property.
    var font: UIFont = UIFont.systemFont(ofSize: 60) {
        didSet { updateFont(font) }
    }
    
    /// The alignment of the text displayed in the DoodleTextView, which only applies if fitOriginalFontSizeToViewWidth is true.
    ///
    /// - Note: Set textAlignment in DoodleViewController to control this property, which will be ignored if fitOriginalFontSizeToViewWidth is false.
    var textAlignment: NSTextAlignment {
        set { updateTextAlignment(newValue) }
        get { return textLabel.textAlignment }
    }
 
    /// The initial insets of the text displayed in the DoodleTextView, which only applies if fitOriginalFontSizeToViewWidth is true. If fitOriginalFontSizeToViewWidth is true, then initialTextInsets sets the initial insets of the displayed text relative to the full size of the DoodleTextView. The user can resize, move, and rotate the text from that starting position, but the overall proportions of the text will stay the same.
    ///
    /// - Note: Set initialTextInsets in DoodleViewController to control this property, which will be ignored if fitOriginalFontSizeToViewWidth is false.
    var initialTextInsets: UIEdgeInsets = .zero {
        didSet { updateInitialTextInsets(initialTextInsets) }
    }
    
    /// If fitOriginalFontSizeToViewWidth is true, then the text will wrap to fit within the width of the DoodleTextView, with the given initialTextInsets, if any. The layout will reflect the textAlignment property as well as the initialTextInsets property. If this is false, then the text will be displayed as a single line, and will ignore any initialTextInsets and textAlignment settings
    ///
    /// - Note: Set fitOriginalFontSizeToViewWidth in DoodleViewController to control this property.
    var fitOriginalFontSizeToViewWidth = false {
        didSet { updateFitOriginalFontSizeToViewWidth(fitOriginalFontSizeToViewWidth) }
    }
    
    var scale: CGFloat = 1 {
        didSet { updateScale(scale) }
    }
    
    var labelFrame: CGRect = .zero {
        didSet {
            updateLabelFrame(labelFrame)
        }
    }
    
    fileprivate var textEditingContainer: UIView?
    fileprivate var textEditingView: UITextView?
    fileprivate var referenceRotateTransform: CGAffineTransform = .identity
    fileprivate var currentRotateTransform: CGAffineTransform = .identity
    fileprivate var referenceCenter: CGPoint = .zero
    fileprivate var activePinchRecognizer: UIPinchGestureRecognizer?
    fileprivate var activeRotationRecognizer: UIRotationGestureRecognizer?
    
    
    // MARK: - Init
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        if fitOriginalFontSizeToViewWidth {
            textLabel.numberOfLines = 0
        }
        self.addSubview(textLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if referenceCenter == .zero {
            textLabel.center = CGPoint(x: self.bounds.midX,
                                       y: self.bounds.midY)
        }
    }
    
    
    // MARK: - Property updates
    
    fileprivate func updateTextAlignment(_ alignment: NSTextAlignment) {
        textLabel.textAlignment = alignment
        sizeLabel()
    }
    
    fileprivate func updateScale(_ scale: CGFloat) {
        textLabel.transform = .identity
        let labelCenter = textLabel.center
        let scaledLabelFrame = CGRect(x: 0,
                                      y: 0,
                                      width: labelFrame.width * scale * 1.05,
                                      height: labelFrame.height * scale * 1.05)
        let currentFontSize = font.pointSize * scale
        
        textLabel.font = font.withSize(currentFontSize)
        textLabel.frame = scaledLabelFrame
        textLabel.center = labelCenter
        textLabel.transform = currentRotateTransform
    }
    
    fileprivate func updateFont(_ font: UIFont) {
        let center = textLabel.center
        textLabel.font = font
        sizeLabel()
        textLabel.center = center
    }
    
    fileprivate func updateInitialTextInsets(_ insets: UIEdgeInsets) {
        sizeLabel()
    }
    
    fileprivate func updateFitOriginalFontSizeToViewWidth(_ isFitting: Bool) {
        textLabel.numberOfLines = isFitting
            ? 0
            : 1
        sizeLabel()
    }
    
    fileprivate func updateLabelFrame(_ frame: CGRect) {
        let labelCenter = textLabel.center
        let scaledLabelFrame = CGRect(x: 0,
                                      y: 0,
                                      width: frame.width * scale * 1.05,
                                      height: frame.height * scale * 1.05)
        let labelTransform = textLabel.transform
        textLabel.transform = .identity
        textLabel.frame = scaledLabelFrame
        textLabel.transform = labelTransform
        textLabel.center = labelCenter
    }
    
    
    // MARK: - Format
    
    fileprivate func sizeLabel() {
        let tempLabel = UILabel()
        tempLabel.text = textString
        tempLabel.font = font
        tempLabel.textAlignment = textAlignment
        
        var insetViewRect: CGRect!

        if fitOriginalFontSizeToViewWidth {
            tempLabel.numberOfLines = 0
            insetViewRect = self.bounds.insetBy(dx: initialTextInsets.left + initialTextInsets.right,
                                                dy: initialTextInsets.top + initialTextInsets.bottom)
        } else {
            tempLabel.numberOfLines = 1
            insetViewRect = CGRect(x: 0,
                                   y: 0,
                                   width: CGFloat.greatestFiniteMagnitude,
                                   height: CGFloat.greatestFiniteMagnitude)
        }
        let originalSize = tempLabel.sizeThatFits(insetViewRect.size)
        tempLabel.frame = CGRect(x: 0,
                                 y: 0,
                                 width: originalSize.width * 1.05,
                                 height: originalSize.height * 1.05)
        tempLabel.center = textLabel.center
        labelFrame = tempLabel.frame
    }
    
    
    // MARK: - Undo

    /// Clears text from the drawing, giving a blank slate.
    ///
    /// - Note: Call clearText or clearAll in DoodleViewController to trigger this method.
    func clearText() {
        scale = 1
        referenceCenter = .zero
        textLabel.transform = .identity
        textString = ""
    }
    
    
    // MARK: - Gesture handling
    
    /// Tells the DoodleTextView to handle a pan gesture.
    ///
    /// - Parameter gesture: The pan gesture recognizer to handle.
    /// - Note: This method is triggered by the DoodleDrawController's internal pan gesture recognizer.
    func handlePan(gesture: UIPanGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            referenceCenter = textLabel.center
        case .changed:
            let panTranslation = gesture.translation(in: self)
            textLabel.center = CGPoint(x: referenceCenter.x + panTranslation.x,
                                       y: referenceCenter.y + panTranslation.y)
        case .ended:
            referenceCenter = textLabel.center
        default: break
        }
    }
    
    /// Tells the DoodleTextView to handle a pinch or rotate gesture.
    ///
    /// - Parameter gesture: The pinch or rotation gesture recognizer to handle.
    /// - Note: This method is triggered by the DoodleDrawController's internal pinch and rotation gesture recognizers.
    func handlePinchOrRotate(gesture: UIGestureRecognizer) {
        switch (gesture.state) {
        case .began:
            if let gesture = gesture as? UIRotationGestureRecognizer {
                currentRotateTransform = referenceRotateTransform
                activeRotationRecognizer = gesture
            } else if let gesture = gesture as? UIPinchGestureRecognizer {
                activePinchRecognizer = gesture
            }
            
        case .changed:
            var currentTransform = referenceRotateTransform
            
            if let gesture = gesture as? UIRotationGestureRecognizer {
                let transform = DoodleTextView.applyGestureRecognizer(gesture, toTransform: referenceRotateTransform)
                currentRotateTransform = transform
            }
            
            currentTransform = DoodleTextView.applyGestureRecognizer(activePinchRecognizer, toTransform: currentTransform)
            currentTransform = DoodleTextView.applyGestureRecognizer(activeRotationRecognizer, toTransform: currentTransform)
            
            textLabel.transform = currentTransform
            
        case .ended:
            if let gesture = gesture as? UIRotationGestureRecognizer {
                referenceRotateTransform = DoodleTextView.applyGestureRecognizer(gesture, toTransform: referenceRotateTransform)
                currentRotateTransform = self.referenceRotateTransform
                activeRotationRecognizer = nil
            } else if let gesture = gesture as? UIPinchGestureRecognizer {
                scale *= gesture.scale
                activePinchRecognizer = nil
            }
        default: break
        }
    }

    fileprivate class func applyGestureRecognizer(_ gesture: UIGestureRecognizer?, toTransform transform: CGAffineTransform) -> CGAffineTransform {
        if let gesture = gesture as? UIRotationGestureRecognizer {
            return transform.rotated(by: gesture.rotation)
        } else if let gesture = gesture as? UIPinchGestureRecognizer {
            return transform.scaledBy(x: gesture.scale, y: gesture.scale)
        } else {
            return transform
        }
    }
    
    
    // MARK: - Image rendering
    
    /// Overlays the text on the given background image.
    ///
    /// - Parameter image: The background image to render text on top of.
    /// - Returns: An image of the rendered drawing on the background image.
    func renderedText(onImage image: UIImage? = nil, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        image?.draw(in: CGRect(origin: .zero, size: size))
        self.layer.render(in: context)
        
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
