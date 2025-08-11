//
//  Dependencies.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import CustomNetworking
import SwiftUI
import Logger
import LoggerFirebaseAnalytics
import LoggerFirebaseCrashlytics
import Router
import Utilities

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

enum DependencyError: Error {
    case missingAPIKey
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "API key for Flickr is missing. Please provide a valid API key in the bundle."
        }
    }
}

@MainActor
struct Dependencies {
    let container: DependencyContainer
    let logManager: LogManager

    /// This initializer wires up all major application services based on the
    /// current build environment:
    ///
    /// - Creates and configures the `LogManager` with the appropriate logging services
    ///   (e.g., console logging, analytics, crash reporting).
    /// - Selects an API client implementation (`ApiProtocol`) according to the configuration.
    /// - Creates the `ImageSearchService` using either mock or live implementations.
    /// - Creates the `LocalSearchHistoryPersistence` service to handle recent search storage.
    /// - Registers all created services into the shared `DependencyContainer`.
    ///
    /// ## Build Configurations
    /// - **`.mock`**:
    ///   - Logging: Console only.
    ///   - API client: Mock.
    ///   - Image search: Mock.
    ///   - Search history: Mock in-memory store.
    /// - **`.dev`**:
    ///   - Logging: Console (verbose), Firebase Analytics, Crashlytics.
    ///   - API client: Live.
    ///   - API key: Loaded from the app bundle’s Info.plist.
    ///   - Image search: Flickr API.
    ///   - Search history: SwiftData.
    /// - **`.prod`**:
    ///   - Logging: Firebase Analytics, Crashlytics.
    ///   - API client: Live.
    ///   - API key: Loaded from the app bundle’s Info.plist.
    ///   - Image search: Flickr API.
    ///   - Search history: SwiftData.
    ///
    /// ## API Key Storage
    /// The Flickr API key is currently stored in the app’s `Info.plist` as
    /// a `Data` field (Base64-encoded bytes) for **simple obfuscation**.
    /// While this hides the key from plain-text inspection, it can still
    /// be recovered from the app bundle and should not be considered secure.
    /// A more secure approach would be to:
    /// - Proxy requests through your own backend and store the API key server-side.
    /// - Use runtime retrieval from a secure remote configuration service.
    /// - Apply stronger runtime obfuscation with integrity checks.
    ///
    /// - Parameter config: The build configuration determining which services to initialize.
    /// - Throws: `DependencyError.missingAPIKey` if a live configuration is used but
    ///           the API key could not be loaded from the bundle.
    init(config: BuildConfiguration) throws {
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
            guard let key = Bundle.main.apiKey(for: Constants.apiKeyName) else {
                throw DependencyError.missingAPIKey
            }
            imageSearchService = FlickrSearchService(
                apiKey: key,
                apiClient: apiService
            )
            localSearchHistoryService = SwiftDataLocalSearchHistoryPersistence()

        case .prod:
            logManager = LogManager(services: [
                FirebaseAnalyticsService(),
                FirebaseCrashlyticsService()
            ])
            apiService = ApiService()
            guard let key = Bundle.main.apiKey(for: Constants.apiKeyName) else {
                throw DependencyError.missingAPIKey
            }
            imageSearchService = FlickrSearchService(
                apiKey: key,
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
