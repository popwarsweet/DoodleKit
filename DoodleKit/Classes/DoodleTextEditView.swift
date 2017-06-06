//
//  DoodleTextEditView.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/6/17.
//
//

import UIKit

internal protocol DoodleTextEditViewDelegate: class {
    /// Called whenever the DoodleTextEditView ends text editing (keyboard entry) mode.
    ///
    /// - Parameter text: The new text string after editing
    func doodleTextEditViewFinishedEditing(withText text: String?)
}

internal class DoodleTextEditView: UIView {
    
    /// The delegate of the DoodleTextEditView, which receives an update when the DoodleTextEditView is finished editing text, with the revised `text`.
    weak var delegate: DoodleTextEditViewDelegate?
    
    /// Whether or not the DoodleTextEditView is actively in edit mode. This property controls whether or not the keyboard is displayed and the DoodleTextEditView is visible.
    ///
    /// - Note: Set the DoodleViewController state to DoodleViewStateEditingText to turn on editing mode in DoodleTextEditView.
    var isEditing = false

    /// The text string the DoodleTextEditView is currently displaying.
    ///
    /// - Note: Set textString in DoodleViewController to control or read this property.
    var text: String {
        set { textView.text = text }
        get { return textView.text }
    }
    
    /// The color of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set textColor in DoodleViewController to control this property.
    var textColor: UIColor = .white
    
    /// The font of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set font in DoodleViewController to control this property. To change the default size of the font, you must also set the fontSize property to the desired font size.
    var font = UIFont.systemFont(ofSize: 40)
    
    /// The font size of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set fontSize in DoodleViewController to control this property, which overrides the size of the font property.
    var fontSize: CGFloat = 40
    
    /// The alignment of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set textAlignment in DoodleViewController to control this property.
    var textAlignment: NSTextAlignment = .left
    
    /// The view insets of the text displayed in the DoodleTextEditView. By default, the text that extends beyond the insets of the text input view will fade out with a gradient to the edges of the DoodleTextEditView. If clipBoundsToEditingInsets is true, then the text will be clipped at the inset instead of fading out.
    ///
    /// - Note: Set textEditingInsets in DoodleViewController to control this property.
    var textEditingInsets: UIEdgeInsets = .zero
    
    /// By default, clipBoundsToEditingInsets is false, and the text that extends beyond the insets of the text input view will fade out with a gradient to the edges of the DoodleTextEditView. If clipBoundsToEditingInsets is true, then the text will be clipped at the inset instead of fading out.
    ///
    /// - Note: Set clipBoundsToEditingInsets in DoodleViewController to control this property.
    var isClippingBoundsToEditingInsets: Bool = false
    
    fileprivate lazy var textView: UITextView = { [unowned self] in
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.keyboardType = .default
        tv.returnKeyType = .done
        tv.clipsToBounds = false
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    fileprivate let textContainer: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var gradientMask: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(white: 1, alpha: 0),
            UIColor(white: 1, alpha: 0.4),
            UIColor(white: 1, alpha: 0.7),
            UIColor(white: 1, alpha: 1),
            UIColor(white: 1, alpha: 1),
            UIColor(white: 1, alpha: 0.7),
            UIColor(white: 1, alpha: 0.4),
            UIColor(white: 1, alpha: 0)
        ]
        return layer
    }()
    
    fileprivate var topGradient: CAGradientLayer = {
       let layer = CAGradientLayer()
        return layer
    }()
    
    fileprivate var bottomGradient: CAGradientLayer = {
        let layer = CAGradientLayer()
        return layer
    }()
    
    fileprivate var textContainerBottomConstraint: NSLayoutConstraint?
    fileprivate var textViewLayoutConstraints: [NSLayoutConstraint]?
    
    
    // MARK: - Init
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        textContainer.isHidden = true
        
        // Add subviews.
        self.addSubview(textContainer)
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                          options: [],
                                                          metrics: nil,
                                                          views: ["view": textContainer])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                          options: [],
                                                          metrics: nil,
                                                          views: ["view": textContainer])
        self.addConstraints(hConstraints)
        self.addConstraints(vConstraints)
        
        textContainer.addSubview(textView)
        updateTextEditingInsets(.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // Notification handling
    
    func keyboardFrameDidChange(notification: Notification) {
        textContainer.layer.removeAllAnimations()
        
        let keyboardRectEnd = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let duration: Double = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        var animationCurve = UIViewAnimationCurve.linear
        if let index = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let value = UIViewAnimationCurve(rawValue:index) {
            animationCurve = value
        }
        
        textContainerBottomConstraint?.constant = keyboardRectEnd.height

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [UIViewAnimationOptions(rawValue: UInt(animationCurve.rawValue))],
            animations: {
                self.textContainer.layoutIfNeeded()
        }, completion: nil)
    }
    
    // Property updates
    
    fileprivate func updateText(_ text: String?) {
        textView.text = text
        textView.setContentOffset(.zero, animated: false)
    }
    
    fileprivate func updateTextEditingInsets(_ inset: UIEdgeInsets) {
        if let textViewLayoutConstraints = textViewLayoutConstraints {
            for constraint in textViewLayoutConstraints {
                constraint.isActive = false
            }
        }
        
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(left)-[view]-(right)-|",
                                                          options: [],
                                                          metrics: ["left": inset.left, "right": inset.right],
                                                          views: ["view": textView])
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[view]-(bottom)-|",
                                                          options: [],
                                                          metrics: ["top": inset.top, "bottom": inset.bottom],
                                                          views: ["view": textView])
        textViewLayoutConstraints = [hConstraints, vConstraints].flatMap { $0 }
        self.addConstraints(textViewLayoutConstraints!)
        
        textView.layoutIfNeeded()
        textView.setContentOffset(.zero, animated:false)
    }
    
    fileprivate func updateFont(_ font: UIFont) {
        textView.font = font
    }
    
    fileprivate func updateFontSize(_ size: CGFloat) {
        textView.font = font.withSize(size)
    }
    
    fileprivate func updateTextAlignment(_ alignment: NSTextAlignment) {
        textView.textAlignment = alignment
    }
    
    fileprivate func updateTextColor(_ color: UIColor) {
        textView.textColor = color
    }
    
    fileprivate func updateIsClippingBoundsToEditingInsets(_ isClipping: Bool) {
        textView.clipsToBounds = isClipping
        setupGradientMask()
    }
    
    fileprivate func updateIsEditing(_ isEditing: Bool) {
        textContainer.isHidden = !isEditing
        self.isUserInteractionEnabled = isEditing
        if isEditing {
            self.backgroundColor = UIColor(white: 0, alpha: 0.5)
            textView.becomeFirstResponder()
        } else {
            self.backgroundColor = .clear
            textView.resignFirstResponder()
            delegate?.doodleTextEditViewFinishedEditing(withText: text)
        }
    }
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupGradientMask()
    }
    
    
    // MARK: - Gradient setup
    
    fileprivate func setupGradientMask() {
        if !isClippingBoundsToEditingInsets {
            textContainer.layer.mask = gradientMask
            
            let percentTopOffset = Double(textEditingInsets.top / textContainer.bounds.height)
            let percentBottomOffset = Double(textEditingInsets.bottom / textContainer.bounds.height)
            
            gradientMask.locations = [
                NSNumber(value: 0),
                NSNumber(value: (0.8 * percentTopOffset)),
                NSNumber(value: (0.9 * percentTopOffset)),
                NSNumber(value: (1 * percentTopOffset)),
                NSNumber(value: (1 - (1 * percentBottomOffset))),
                NSNumber(value: (1 - (0.9 * percentBottomOffset))),
                NSNumber(value: (1 - (0.8 * percentBottomOffset))),
                NSNumber(value: 1)
            ]

            gradientMask.frame = CGRect(origin: .zero,
                                        size: textContainer.bounds.size)
        } else {
            textContainer.layer.mask = nil
        }
    }
}


// MARK: - UITextViewDelegate

extension DoodleTextEditView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            isEditing = false
            return false
        }
        
        if (textView.text as NSString).length + ((text as NSString).length - range.length) > 70 {
            return false
        }

        if (text as NSString).rangeOfCharacter(from: CharacterSet.newlines).location != NSNotFound {
            return false
        }
        
        return true
    }
}
