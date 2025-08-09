//
//  Builder.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

@MainActor
protocol Builder {
    func build() -> AnyView
}
