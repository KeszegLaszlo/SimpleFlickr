//
//  CoreRouter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

@MainActor
struct CoreRouter: GlobalRouter {
    let router: AnyRouter
    let builder: CoreBuilder
}
