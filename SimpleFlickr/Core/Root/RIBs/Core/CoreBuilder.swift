//
//  CoreBuilder.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import UserInterface

@MainActor
struct CoreBuilder: Builder {
    let interactor: CoreInteractor

    func build() -> AnyView {
        Text("Core").any()
    }
}
