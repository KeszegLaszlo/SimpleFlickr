//
//  AnyDestination.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

public struct AnyDestination: Hashable, @unchecked Sendable {
    let id = UUID().uuidString
    var destination: AnyView

    public init<T: View>(destination: T) {
        self.destination = AnyView(destination)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
