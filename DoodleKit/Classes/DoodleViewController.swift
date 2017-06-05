//
//  DoodleViewController.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/5/17.
//
//

import UIKit

public protocol DoodleViewControllerDelegate: class {
    /// Called whenever the JotViewController begins or ends text editing (keyboard entry) mode.
    ///
    /// - Parameters:
    ///   - doodleViewController: The draw text view controller.
    ///   - isEditingText: `true` if entering edit (keyboard text entry) mode, `false` if exiting edit mode.
    func doodleViewController(doodleViewController: DoodleViewController, isEditingText: Bool)
    
    /// Tells the delegate to handle a touchesBegan event on the drawing container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system where the touch began.
    func doodleDrawingContainerTouchBeganAtPoint(touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesMoved event on the drawing container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch moved.
    func doodleDrawingContainerTouchMovedToPoint(touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesEnded event on the drawing container.
    func doodleDrawingContainerTouchEnded()
    
    /// Tells the delegate to handle a touchesBegan event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system where the touch began.
    func doodleTextContainerTouchBeganAtPoint(touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesMoved event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch moved.
    func doodleTextContainerTouchMovedToPoint(touchPoint: CGPoint)
    
    /// Tells the delegate to handle a touchesEnded event on the text container.
    ///
    /// - Parameter touchPoint: The point in this view's coordinate system to which the touch ended.
    func doodleTextContainerTouchEndedAtPoint(touchPoint: CGPoint)
}

public class DoodleViewController: UIViewController {

    /// The delegate of the JotViewController instance.
    weak var delegate: DoodleViewControllerDelegate?
    
    /// The state of the JotViewController. Change the state between JotViewStateDrawing and JotViewStateText in response to your own editing controls to toggle between the different modes. Tapping while in JotViewStateText will automatically switch to JotViewStateEditingText, and tapping the keyboard's Done button will automatically switch back to JotViewStateText.
    ///
    /// - Note: The JotViewController's delegate will get updates when it enters and exits text editing mode, in case you need to update your interface to reflect this.
    var state: DoodleViewState = .default
    
    /// The font of the text displayed in the JotTextView and JotTextEditView.
    ///
    /// - Note: To change the default size of the font, you must also set the fontSize property to the desired font size.
    var font: UIFont = UIFont.systemFont(ofSize: 16)
    
    /// The initial font size of the text displayed in the JotTextView before pinch zooming, and the fixed font size of the JotTextEditView.
    ///
    /// - Note: This property overrides the size of the font property.
    var fontSize: CGFloat = 16
    
    /// The color of the text displayed in the JotTextView and the JotTextEditView.
    var textColor: UIColor = .black
    
    // Text shadow properties.
    var textShadowColor: UIColor = .black
    var textShadowOpacity: CGFloat = 0
    var textShadowOffset: CGSize = .zero
    var textShadowBlurRadius: CGFloat = 0
    
    /// The text string the JotTextView and JotTextEditView are displaying.
    var textString: String = ""
    
    /// The alignment of the text displayed in the JotTextView, which only applies if fitOriginalFontSizeToViewWidth is true, and the alignment of the text displayed in the JotTextEditView regardless of other settings.
    var textAlignment: NSTextAlignment = .center
    
    
     /// Sets the stroke color for drawing. Each drawing path can have its own stroke color.
    var drawingColor: UIColor = .black
    
    ///Sets the stroke width for drawing if constantStrokeWidth is true, or sets the base strokeWidth for variable drawing paths constantStrokeWidth is false.
    var drawingStrokeWidth: CGFloat = 0
    
     /// Set to `true` if you want the stroke width for drawing to be constant, `false` if the stroke width should vary depending on drawing speed.
    var drawingConstantStrokeWidth: Bool = false
    
    /// The view insets of the text displayed in the JotTextEditView. By default, the text that extends beyond the insets of the text input view will fade out with a gradient to the edges of the JotTextEditView. If clipBoundsToEditingInsets is true, then the text will be clipped at the inset instead of fading out.
    var textEditingInsets: UIEdgeInsets = .zero
    
    /// The initial insets of the text displayed in the JotTextView, which only applies if fitOriginalFontSizeToViewWidth is true. If fitOriginalFontSizeToViewWidth is true, then initialTextInsets sets the initial insets of the displayed text relative to the full size of the JotTextView. The user can resize, move, and rotate the text from that starting position, but the overall proportions of the text will stay the same.
    ///
    /// - Note: This will be ignored if fitOriginalFontSizeToViewWidth is false.
    var initialTextInsets: UIEdgeInsets = .zero
    
    /// If fitOriginalFontSizeToViewWidth is true, then the text will wrap to fit within the width of the JotTextView, with the given initialTextInsets, if any. The layout will reflect the textAlignment property as well as the initialTextInsets property. If this is false, then the text will be displayed as a single line, and will ignore any initialTextInsets and textAlignment settings.
    var fitOriginalFontSizeToViewWidth = false
    
    /// By default, clipBoundsToEditingInsets is false, and the text that extends beyond the insets of the text input view in the JotTextEditView will fade out with a gradient to the edges of the JotTextEditView. If clipBoundsToEditingInsets is true, then the text will be clipped at the inset instead of fading out in the JotTextEditView.
    var clipBoundsToEditingInsets = false
    
    fileprivate(set) lazy var drawingContainer: DoodleDrawingContainerView = {
        let view = DoodleDrawingContainerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    fileprivate(set) lazy var drawView: DoodleDrawView = {
        let view = DoodleDrawView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
//    fileprivate(set) lazy var textView: DoodleTextView
    
//    @property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
//    @property (nonatomic, strong) UIPinchGestureRecognizer *pinchRecognizer;
//    @property (nonatomic, strong) UIRotationGestureRecognizer *rotationRecognizer;
//    @property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
//    @property (nonatomic, strong, readwrite) JotDrawingContainer *drawingContainer;
//    @property (nonatomic, strong) JotDrawView *drawView;
//    @property (nonatomic, strong) JotTextEditView *textEditView;
    
    /// Removes last stroke. A stroke is all paths that have been created from touch down to touch up.
    func undoLastStroke() {
        
    }
    
    /// Clears all paths from the drawing in and sets the text to an empty string, giving a blank slate.
    func clearAll() {
        
    }
    
    
    /// Clears only the drawing, leaving the text alone.
    func clearDrawing() {
        
    }
    
    /// Clears only the text, leaving the drawing alone.
    func clearText() {
        
    }
    
    
    /// Overlays the drawing and text on the given background image at the full resolution of the image.
    ///
    /// - Parameter image: The background image to draw on top of.
    /// - Returns: An image of the rendered drawing and text on the background image.
    func renderImage(onImage image: UIImage) -> UIImage? {
        return nil
    }
    
    /// Renders the drawing and text at the view's size with a transparent background.
    ///
    /// - Returns: An image of the rendered drawing and text.
    func renderImage() -> UIImage? {
        return nil
    }
    
    /// Renders the drawing and text at the view's size with a colored background.
    ///
    /// - Parameter backgroundColor: The background color to render the image on.
    /// - Returns: An image of the rendered drawing and text on a colored background.
    func renderImage(onColor backgroundColor: UIColor) -> UIImage? {
        return nil
    }
    
    /// Renders the drawing and text at the view's size multiplied by the given scale with a transparent background.
    ///
    /// - Parameter scale: The scale to render the image at.
    /// - Parameter backgroundColor: The background color to render the image on.
    /// - Returns: An image of the rendered drawing and text.
    func renderImage(withScale scale: CGFloat, onColor backgroundColor: UIColor = .clear) -> UIImage? {
        return nil
    }
    
    
    // MARK: - View lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
}

public extension DoodleViewController {
    public enum DoodleViewState {
        case `default`
        /// The drawing state, where drawing with touch gestures will create colored lines in the view.
        case drawing
        /// The text state, where pinch, pan, and rotate gestures will manipulate the displayed text, and a tap gesture will switch to text editing mode.
        case text
        /// The text editing state, where the contents of the text string can be edited with the keyboard.
        case editingText
    }
}
