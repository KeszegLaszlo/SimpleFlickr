//
//  Binding+Extensions.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

extension Binding where Value == Bool {

    init<T: Sendable>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}
