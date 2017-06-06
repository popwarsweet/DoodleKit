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
    var isEditing = false {
        didSet { updateIsEditing(isEditing) }
    }

    /// The text string the DoodleTextEditView is currently displaying.
    ///
    /// - Note: Set textString in DoodleViewController to control or read this property.
    var textString: String {
        set { textView.text = textString }
        get { return textView.text }
    }
    
    /// The color of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set textColor in DoodleViewController to control this property.
    var textColor: UIColor = .white {
        didSet { updateTextColor(textColor) }
    }
    
    /// The font of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set font in DoodleViewController to control this property. To change the default size of the font, you must also set the fontSize property to the desired font size.
    var font = UIFont.systemFont(ofSize: 40) {
        didSet { updateFont(font) }
    }
    
    /// The font size of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set fontSize in DoodleViewController to control this property, which overrides the size of the font property.
    var fontSize: CGFloat = 40 {
        didSet { updateFontSize(fontSize) }
    }
    
    /// The alignment of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set textAlignment in DoodleViewController to control this property.
    var textAlignment: NSTextAlignment {
        get { return textView.textAlignment }
        set { textView.textAlignment = newValue }
    }
    
    /// The view insets of the text displayed in the DoodleTextEditView.
    ///
    /// - Note: Set textEditingInsets in DoodleViewController to control this property.
    var textEditingInsets: UIEdgeInsets = .zero {
        didSet { updateTextEditingInsets(textEditingInsets) }
    }
    
    fileprivate lazy var textView: UITextView = { [unowned self] in
        let tv = UITextView()
        tv.textColor = self.textColor
        tv.font = self.font.withSize(self.fontSize)
        tv.backgroundColor = .clear
        tv.keyboardType = .default
        tv.returnKeyType = .done
        tv.clipsToBounds = false
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textAlignment = .center
        return tv
    }()
    
    fileprivate let textContainer: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        textContainer.pinEdgesToSuperview(edges: [.left, .top, .right])
        textContainerBottomConstraint = textContainer.pinBottomToSuperview()
        
        textContainer.addSubview(textView)
        updateTextEditingInsets(.zero)
        
        // Add notification listeners.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardFrameDidChange(notification:)),
            name: .UIKeyboardDidChangeFrame,
            object: nil)
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
        
        textContainerBottomConstraint?.constant = -keyboardRectEnd.height

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
                textView.removeConstraint(constraint)
            }
        }
        
        textViewLayoutConstraints = textView.pinEdgesToSuperview(edges: [.all], padding: inset)
        textView.layoutIfNeeded()
        textView.setContentOffset(.zero, animated:false)
    }
    
    fileprivate func updateFont(_ font: UIFont) {
        textView.font = font
    }
    
    fileprivate func updateFontSize(_ size: CGFloat) {
        textView.font = font.withSize(size)
    }
    
    fileprivate func updateTextColor(_ color: UIColor) {
        textView.textColor = color
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
            delegate?.doodleTextEditViewFinishedEditing(withText: textString)
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
