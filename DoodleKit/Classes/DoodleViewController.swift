//
//  DoodleViewController.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/5/17.
//
//

import UIKit

public protocol DoodleViewControllerDelegate: AnyObject {
    /// Called whenever the DoodleViewController begins or ends text editing (keyboard entry) mode.
    ///
    /// - Parameters:
    ///   - doodleViewController: The draw text view controller.
    ///   - isEditingText: `true` if entering edit (keyboard text entry) mode, `false` if exiting edit mode.
    func doodleViewController(_ doodleViewController: DoodleViewController, isEditingText: Bool)
    
    /// Tells the delegate to handle a touchesBegan event on the drawing container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system where the touch began.
    func doodleDrawingContainerTouchBegan(at touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesMoved event on the drawing container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch moved.
    func doodleDrawingContainerTouchMoved(to touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesEnded event on the drawing container.
    func doodleDrawingContainerTouchEnded()
    
    /// Tells the delegate to handle a touchesBegan event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system where the touch began.
    func doodleTextContainerTouchBegan(at touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesMoved event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch moved.
    func doodleTextContainerTouchMoved(to touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesEnded event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch ended.
    func doodleTextContainerTouchEnded(at touchPoint: CGPoint)
}

public class DoodleViewController: UIViewController {

    /// The delegate of the DoodleViewController instance.
    public weak var delegate: DoodleViewControllerDelegate?
    
    /// The state of the DoodleViewController. Change the state between `DoodleViewState.drawing` and `DoodleViewState.text` in response to your own editing controls to toggle between the different modes. Tapping while in `DoodleViewState.text` will automatically switch to `DoodleViewState.editingText`, and tapping the keyboard's Done button will automatically switch back to `DoodleViewState.text`.
    ///
    /// - Note: The DoodleViewController's delegate will get updates when it enters and exits text editing mode, in case you need to update your interface to reflect this.
    public var state: DoodleViewState = .default {
        didSet { updateState(state, oldValue: oldValue) }
    }
    
    /// The font of the text displayed in the DoodleTextView and DoodleTextEditView.
    ///
    /// - Note: To change the default size of the font, you must also set the fontSize property to the desired font size.
    public var font: UIFont = UIFont.systemFont(ofSize: 37) {
        didSet { updateFont(font) }
    }
    
    /// The color of the text displayed in the DoodleTextView and the DoodleTextEditView.
    public var textColor: UIColor = .white {
        didSet { updateTextColor(textColor) }
    }
    
    // Text shadow properties.
    public var textShadowColor: UIColor = .black {
        didSet { updateTextShadowColor(textShadowColor) }
    }
    public var textShadowOpacity: CGFloat = 0 {
        didSet { updateTextShadowOpacity(textShadowOpacity) }
    }
    public var textShadowOffset: CGSize = .zero {
        didSet { updateTextShadowOffset(textShadowOffset) }
    }
    public var textShadowBlurRadius: CGFloat = 0 {
        didSet { updateTextShadowBlurRadius(textShadowBlurRadius) }
    }
    
    /// The text string the DoodleTextView and DoodleTextEditView are displaying.
    public var textString: String = "" {
        didSet { updateTextString(textString) }
    }
    
    /// The alignment of the text displayed in the DoodleTextView, which only applies if fitOriginalFontSizeToViewWidth is true, and the alignment of the text displayed in the DoodleTextEditView regardless of other settings.
    public var textAlignment: NSTextAlignment = .center {
        didSet { updateTextAlignment(textAlignment) }
    }
    
     /// Sets the stroke color for drawing. Each drawing path can have its own stroke color.
    public var drawingColor: UIColor = .black {
        didSet { updateDrawingColor(drawingColor) }
    }
    
    ///Sets the stroke width for drawing if constantStrokeWidth is true, or sets the base strokeWidth for variable drawing paths constantStrokeWidth is false.
    public var drawingStrokeWidth: CGFloat = 0 {
        didSet { updateDrawingStrokeWidth(drawingStrokeWidth) }
    }
    
    /// Set to `true` if you want the stroke width for drawing to be constant, `false` if the stroke width should vary depending on drawing speed.
    public var drawingConstantStrokeWidth: Bool = false {
        didSet { updateIsDrawingConstantStrokeWidth(drawingConstantStrokeWidth) }
    }
    
    /// The view insets of the text displayed in the DoodleTextEditView.
    public var textEditingInsets: UIEdgeInsets = .zero {
        didSet { updateTextEditingInsets(textEditingInsets) }
    }
    
    /// The initial insets of the text displayed in the DoodleTextView, which only applies if fitOriginalFontSizeToViewWidth is true. If fitOriginalFontSizeToViewWidth is true, then initialTextInsets sets the initial insets of the displayed text relative to the full size of the DoodleTextView. The user can resize, move, and rotate the text from that starting position, but the overall proportions of the text will stay the same.
    ///
    /// - Note: This will be ignored if fitOriginalFontSizeToViewWidth is false.
    public var initialTextInsets: UIEdgeInsets = .zero {
        didSet { updateInitialTextInsets(initialTextInsets) }
    }
    
    /// If fitOriginalFontSizeToViewWidth is true, then the text will wrap to fit within the width of the DoodleTextView, with the given initialTextInsets, if any. The layout will reflect the textAlignment property as well as the initialTextInsets property. If this is false, then the text will be displayed as a single line, and will ignore any initialTextInsets and textAlignment settings.
    public var fitOriginalFontSizeToViewWidth = true {
        didSet { updateFitOriginalFontSizeToViewWidth(fitOriginalFontSizeToViewWidth) }
    }
    
    // Drawing subviews
    fileprivate(set) lazy var drawingContainer: DoodleDrawingContainerView = { [unowned self] in
        let view = DoodleDrawingContainerView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
       return view
    }()
    fileprivate(set) lazy var drawView: DoodleDrawView = {
        let view = DoodleDrawView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Text subviews
    public fileprivate(set) lazy var textView: DoodleTextView = { [unowned self] in
        let tv = DoodleTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = self.font
        tv.textColor = self.textColor
        return tv
    }()
    fileprivate lazy var textEditView: DoodleTextEditView = { [unowned self] in
        let view = DoodleTextEditView()
        view.font = self.font
        view.textColor = self.textColor
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Gesture recognizers
    fileprivate var tapRecognizer: UITapGestureRecognizer?
    fileprivate var pinchRecognizer: UIPinchGestureRecognizer?
    fileprivate var rotationRecognizer: UIRotationGestureRecognizer?
    fileprivate var panRecognizer: UIPanGestureRecognizer?
    
    fileprivate func addGestureRecognizers() {
        pinchRecognizer = UIPinchGestureRecognizer(target: self,
                                                   action: #selector(handlePinchOrRotate(gesture:)))
        rotationRecognizer = UIRotationGestureRecognizer(target: self,
                                                         action: #selector(handlePinchOrRotate(gesture:)))
        panRecognizer = UIPanGestureRecognizer(target: self,
                                               action: #selector(handlePan(gesture:)))
        tapRecognizer = UITapGestureRecognizer(target: self,
                                               action: #selector(handleTap(gesture:)))
        
        let gestures: [UIGestureRecognizer] = [
            pinchRecognizer!,
            rotationRecognizer!,
            panRecognizer!,
            tapRecognizer!
        ]
        gestures.forEach {
            $0.delegate = self
            drawingContainer.addGestureRecognizer($0)
        }
    }
    
    
    // MARK: - Init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addGestureRecognizers()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGestureRecognizers()
    }
    
    
    // MARK: - View lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        drawingContainer.clipsToBounds = true
        
        self.view.addSubview(drawingContainer)
        drawingContainer.pinEdgesToSuperview()
        
        drawingContainer.addSubview(drawView)
        drawView.pinEdgesToSuperview()
        
        drawingContainer.addSubview(textView)
        textView.pinEdgesToSuperview()
        
        self.view.addSubview(textEditView)
        textEditView.pinEdgesToSuperview()
    }
    
    
    // MARK: - Property updates
    
    fileprivate func updateState(_ state: DoodleViewState, oldValue: DoodleViewState) {
        guard state != oldValue else { return }
        
        if state == .editingText {
            textView.isHidden = true
            textEditView.isEditing = true
        } else {
            textView.isHidden = false
            textEditView.isEditing = false
        }
        
        if state == .editingText {
            delegate?.doodleViewController(self, isEditingText: true)
        }
        
        if state == .text {
            drawingContainer.isMultipleTouchEnabled = true
            tapRecognizer?.isEnabled = true
            panRecognizer?.isEnabled = true
            pinchRecognizer?.isEnabled = true
            rotationRecognizer?.isEnabled = true
        } else {
            drawingContainer.isMultipleTouchEnabled = false
            tapRecognizer?.isEnabled = false
            panRecognizer?.isEnabled = false
            pinchRecognizer?.isEnabled = false
            rotationRecognizer?.isEnabled = false
        }
    }
    
    fileprivate func updateTextString(_ textString: String) {
        textView.textString = textString
        textEditView.textString = textString
    }
    
    fileprivate func updateFont(_ font: UIFont) {
        textView.font = font
        textEditView.font = font
    }
    
    fileprivate func updateTextAlignment(_ alignment: NSTextAlignment) {
        textView.textAlignment = alignment
        textEditView.textAlignment = alignment
    }
    
    fileprivate func updateTextColor(_ color: UIColor) {
        textView.textColor = color
        textEditView.textColor = color
    }
    
    fileprivate func updateTextShadowColor(_ color: UIColor) {
        textView.textLabel.layer.shadowColor = color.cgColor
    }
    
    fileprivate func updateTextShadowOpacity(_ opacity: CGFloat) {
        textView.textLabel.layer.shadowOpacity = Float(opacity)
    }
    
    fileprivate func updateTextShadowOffset(_ offset: CGSize) {
        textView.textLabel.shadowOffset = offset
    }
    
    fileprivate func updateTextShadowBlurRadius(_ radius: CGFloat) {
        textView.textLabel.layer.shadowRadius = radius
    }
    
    fileprivate func updateInitialTextInsets(_ insets: UIEdgeInsets) {
        textView.initialTextInsets = insets
    }
    
    fileprivate func updateTextEditingInsets(_ insets: UIEdgeInsets) {
        textEditView.textEditingInsets = insets
    }
    
    fileprivate func updateFitOriginalFontSizeToViewWidth(_ isFitting: Bool) {
        self.textView.fitOriginalFontSizeToViewWidth = isFitting
        if isFitting {
            textEditView.textAlignment = textAlignment
        } else {
            textEditView.textAlignment = .left
        }
    }
    
    fileprivate func updateDrawingColor(_ color: UIColor) {
        drawView.strokeColor = color
    }
    
    fileprivate func updateDrawingStrokeWidth(_ strokeWidth: CGFloat) {
        drawView.strokeWidth = strokeWidth
    }
    
    fileprivate func updateIsDrawingConstantStrokeWidth(_ isConstantWidth: Bool) {
        drawView.isStrokeWidthConstant = isConstantWidth
    }
}


// MARK: - Undo

extension DoodleViewController {
    /// Removes last stroke. A stroke is all paths that have been created from touch down to touch up.
    public func undoLastStroke() {
        drawView.undoLastStroke()
    }
 
    /// Clears all paths from the drawing in and sets the text to an empty string, giving a blank slate.
    public func clearAll() {
        clearDrawing()
        clearText()
    }
 
    /// Clears only the drawing, leaving the text alone.
    public func clearDrawing() {
        drawView.clearDrawing()
    }
    
    /// Clears only the text, leaving the drawing alone.
    public func clearText() {
        textView.clearText()
    }
}


// MARK: - Rendering

extension DoodleViewController {
    /// Overlays the drawing and text on the given background image at the full resolution of the image.
    ///
    /// - Parameter image: The background image to draw on top of.
    /// - Returns: An image of the rendered drawing and text on the background image.
    public func renderedImage(onImage image: UIImage? = nil) -> UIImage? {
        let drawing = drawView.renderedDrawing(onImage: image, size: self.view.bounds.size)
        let drawingAndText = textView.renderedText(onImage: drawing, size: self.view.bounds.size)
        return drawingAndText
    }
    
    /// Renders the drawing and text at the view's size multiplied by the given scale with a transparent background.
    ///
    /// - Parameter scale: The scale to render the image at.
    /// - Parameter backgroundColor: The background color to render the image on.
    /// - Returns: An image of the rendered drawing and text.
    public func renderedImage(onColor backgroundColor: UIColor = .clear) -> UIImage? {
        let backgroundImage = UIImage.imageWithColor(backgroundColor, ofSize: self.view.bounds.size)
        let drawing = drawView.renderedDrawing(onImage: backgroundImage, size: self.view.bounds.size)
        return drawing
    }
}


// MARK: - Gesture handling

extension DoodleViewController {
    @objc
    func handleTap(gesture: UITapGestureRecognizer) {
        // Set to text editing on tap.
        if state != .editingText {
            state = .editingText
        }
    }
    
    @objc
    func handlePan(gesture: UIPanGestureRecognizer) {
        textView.handlePan(gesture: gesture)
        
        if state == .text {
            // Forward to text view.
            let location = gesture.location(in: self.textView)
            switch gesture.state {
            case .began:
                delegate?.doodleTextContainerTouchBegan(at: location)
            case .changed:
                delegate?.doodleTextContainerTouchMoved(to: location)
            case .ended, .cancelled:
                delegate?.doodleTextContainerTouchEnded(at: location)
            default: break
            }
        }
    }
    
    @objc
    func handlePinchOrRotate(gesture: UIGestureRecognizer) {
        textView.handlePinchOrRotate(gesture: gesture)
    }
}


// MARK: - DoodleDrawingContainerViewDelegate

extension DoodleViewController: DoodleDrawingContainerViewDelegate {
    func doodleDrawingContainerViewTouchBegan(at point: CGPoint) {
        if state == .drawing {
            drawView.drawTouchBegan(at: point)
            delegate?.doodleDrawingContainerTouchBegan(at: point)
        }
    }
    
    func doodleDrawingContainerViewTouchMoved(to point: CGPoint) {
        if state == .drawing {
            drawView.drawTouchPointMoved(to: point)
            delegate?.doodleDrawingContainerTouchMoved(to: point)
        }
    }
    
    func doodleDrawingContainerViewTouchEnded(at point: CGPoint) {
        if state == .drawing {
            drawView.drawTouchEnded()
            delegate?.doodleDrawingContainerTouchEnded()
        }
    }
}


// MARK: - UIGestureRecognizerDelegate

extension DoodleViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer {
            return true
        } else {
            return false
        }
    }
}


// MARK: - DoodleTextEditViewDelegate

extension DoodleViewController: DoodleTextEditViewDelegate {
    func doodleTextEditViewFinishedEditing(withText text: String?) {
        if state == .editingText {
            state = .text
        }
        updateTextString(text ?? "")
        delegate?.doodleViewController(self, isEditingText: false)
    }
}


// MARK: - DoodleViewState

public extension DoodleViewController {
    enum DoodleViewState {
        case `default`
        /// The drawing state, where drawing with touch gestures will create colored lines in the view.
        case drawing
        /// The text state, where pinch, pan, and rotate gestures will manipulate the displayed text, and a tap gesture will switch to text editing mode.
        case text
        /// The text editing state, where the contents of the text string can be edited with the keyboard.
        case editingText
    }
}
