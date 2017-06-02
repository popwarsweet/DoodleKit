//
//  DoodleDrawingContainerView.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/2/17.
//
//

import UIKit

protocol DoodleDrawingContainerViewDelegate: class {
    /// Tells the delegate to handle a touchesBegan event.
    ///
    /// - Parameter point: The point in this view's coordinate system where the touch began.
    func doodleDrawingContainerViewTouchBegan(at point: CGPoint)
    
    /// Tells the delegate to handle a touchesMoved event.
    ///
    /// - Parameter point: The point in this view's coordinate system to which the touch moved.
    func doodleDrawingContainerViewTouchMoved(to point: CGPoint)
    
    /// Tells the delegate to handle a touchesEnded event.
    ///
    /// - Parameter point: The poin in this view's coordinate system.
    func doodleDrawingContainerViewTouchEnded(at point: CGPoint)
}


class DoodleDrawingContainerView: UIView {
    weak var delegate: DoodleDrawingContainerViewDelegate?
}
