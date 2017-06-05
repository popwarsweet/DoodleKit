//
//  DrawablePath.swift
//  Pods
//
//  Created by Kyle Zaragoza on 6/2/17.
//
//

import Foundation

internal protocol DrawablePath: Equatable {
    func draw(inContext: CGContext)
}

internal class DoodlePath: DrawablePath {
    func draw(inContext: CGContext) { }
    static func ==(lhs: DoodlePath, rhs: DoodlePath) -> Bool { return true }
}
