//
//  CoreInteractor.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

@MainActor
struct CoreInteractor {
    private let logManager: LogManager

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
    }
}
