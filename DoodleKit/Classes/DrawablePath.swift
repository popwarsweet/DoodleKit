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
    func equals(_ other: Self) -> Bool
}

internal class DoodlePath: DrawablePath {
    func draw(inContext: CGContext) { }
    func equals(_ other: DoodlePath) -> Bool { return true }
    static func ==(lhs: DoodlePath, rhs: DoodlePath) -> Bool { return lhs.equals(rhs) }
}
