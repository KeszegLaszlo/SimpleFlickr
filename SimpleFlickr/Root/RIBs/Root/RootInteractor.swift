//
//  RootInteractor.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

@MainActor
struct RootInteractor {
    private let logManager: LogManager

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
    }
}
