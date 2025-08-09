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
import CustomNetworking

typealias AnyRouter = Router.RouterProtocol
typealias RouterView = Router.RouterView
typealias LogManager = Logger.LogManager
typealias LoggableEvent = Logger.LoggableEvent
typealias LogType = Logger.LogType
typealias LogService = Logger.LogService
typealias AnyLoggableEvent = Logger.AnyLoggableEvent
typealias FirebaseAnalyticsService = LoggerFirebaseAnalytics.FirebaseAnalyticsService

typealias ApiProtocol = CustomNetworking.ApiProtocol
typealias EndpointProvider = CustomNetworking.EndpointProvider
typealias RequestMethod = CustomNetworking.RequestMethod

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let logManager: LogManager

    // swiftlint:disable:next function_body_length
    init(config: BuildConfiguration) {
        let imageSearchService: any ImageSearchService
        let localSearchHistoryService: any LocalSearchHistoryPersistence
        let apiService: any ApiProtocol

        switch config {
        case .mock:
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
            ])
            apiService = MockApiService()
            imageSearchService = MockImageSearchService(apiClient: apiService)
            localSearchHistoryService = MockLocalSearchHistoryPersistence()

        case .dev:
            logManager = LogManager(services: [
                ConsoleService(printParameters: true),
                FirebaseAnalyticsService(),
                FirebaseCrashlyticsService()
            ])
            apiService = ApiService()
            imageSearchService = FlickrSearchService(
                apiKey: "65803e8f6e4a3982200621cad356be51", //TODO: Remove from here
                apiClient: apiService
            )
            localSearchHistoryService = SwiftDataLocalSearchHistoryPersistence()

        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                FirebaseCrashlyticsService()
            ])
            apiService = ApiService()
            imageSearchService = FlickrSearchService(
                apiKey: "65803e8f6e4a3982200621cad356be51", //TODO: Remove from here
                apiClient: apiService
            )
            localSearchHistoryService = SwiftDataLocalSearchHistoryPersistence()
        }

        let container = DependencyContainer()
        container.register(LogManager.self, service: logManager)
        container.register(ImageSearchService.self, service: imageSearchService)
        container.register(LocalSearchHistoryPersistence.self, service: localSearchHistoryService)
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
    let logManager: LogManager
    let apiService: any ApiProtocol
    let imageSearchService: any ImageSearchService
    let localSearchHistoryService: any LocalSearchHistoryPersistence

    init() {
        self.logManager = LogManager(services: [])
        self.apiService = MockApiService()
        self.imageSearchService = MockImageSearchService(apiClient: apiService)
        localSearchHistoryService = MockLocalSearchHistoryPersistence()
    }

    func container() -> DependencyContainer {
        let container = DependencyContainer()

        container.register(LogManager.self, service: logManager)
        container.register(ImageSearchService.self, service: imageSearchService)
        container.register(LocalSearchHistoryPersistence.self, service: localSearchHistoryService)

        return container
    }
}

