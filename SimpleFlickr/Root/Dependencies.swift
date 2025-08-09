//
//  Dependencies.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import Logger
import LoggerFirebaseAnalytics
import LoggerFirebaseCrashlytics
import Router

typealias AnyRouter = Router.RouterProtocol
typealias RouterView = Router.RouterView
typealias LogManager = Logger.LogManager
typealias LoggableEvent = Logger.LoggableEvent
typealias LogType = Logger.LogType
typealias LogService = Logger.LogService
typealias AnyLoggableEvent = Logger.AnyLoggableEvent
typealias FirebaseAnalyticsService = LoggerFirebaseAnalytics.FirebaseAnalyticsService

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let logManager: LogManager

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {

        switch config {
        case .mock:
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])

        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                FirebaseCrashlyticsService()
            ])

        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                FirebaseCrashlyticsService()
            ])

        }
                
        let container = DependencyContainer()

        self.container = container
    }
}

extension View {
    func previewEnvironment(isSignedIn: Bool = true) -> some View {
        self
            .environment(LogManager(services: []))
    }
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    func container() -> DependencyContainer {
        let container = DependencyContainer()

        container.register(LogManager.self, service: logManager)

        return container
    }

    let logManager: LogManager

    init(isSignedIn: Bool = true) {
        self.logManager = LogManager(services: [])
    }
}
