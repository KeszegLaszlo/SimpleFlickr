//
//  ImageFetcherManager.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import Logger

/// Manages image search, pagination, caching, logging, and local search history.
///
/// `ImageSearchManager` coordinates user-initiated image searches and provides:
/// - In-memory per-query cache with next-page tracking.
/// - Paged network fetching via `ImageSearchService`.
/// - Structured logging via `LogManager`.
/// - Persistence of recent searches via `LocalSearchHistoryPersistence`.
///
/// ### Threading
/// The manager is `@MainActor` because it is observed by UI. Network work is awaited
/// and the results are merged back on the main actor.
///
/// ### Caching policy
/// Cache is keyed by the query string and stores the accumulated items and the
/// next page to request. `searchImages` returns **only newly fetched items**; callers
/// can combine with previously returned values if needed. Set `forceRefresh = true`
/// to ignore cache for the first page.
///
/// ### Search history policy
/// `getSearchHistory()` intentionally **excludes** the most recent search entry, while
/// `recentSearch()` returns it. This keeps the "last used" item separate from the list UI.
@MainActor
@Observable
class ImageSearchManager {
    private enum ImageConstants {
        static let perPage = 20
    }

    private let service: any ImageSearchService
    private let localService: any LocalSearchHistoryPersistence
    private let logManager: LogManager

    private var imageCache: [String: (items: [ImageAsset], nextPage: Int)] = [:]

    /// Creates a new manager.
    ///
    /// - Parameters:
    ///   - service: Image search backend (mock or live).
    ///   - localService: Persistence for recent searches/history.
    ///   - logManager: Aggregates analytics/crash/console logging.
    init(
        service: any ImageSearchService,
        localService: any LocalSearchHistoryPersistence,
        logManager: LogManager
    ) {
        self.service = service
        self.localService = localService
        self.logManager = logManager
    }

    /// Adds a search entry to the persistent recent history.
    ///
    /// - Parameter seach: The domain model representing a user search.
    /// - Throws: Rethrows persistence errors.
    func addRecentSearch(seach: SearchElementModel) throws {
        try localService.addRecentSearch(seach: seach)
    }

    /// Returns the stored search history **excluding** the most recent search.
    ///
    /// Useful for list UIs where the latest item is shown separately.
    /// - Returns: Array of older search entries in persistence order.
    /// - Throws: Rethrows persistence errors.
    func getSearchHistory() throws -> [SearchElementModel] {
        // Return history excluding the most recent item
        var history = try localService.getSearchHistory()
        if let recent = try localService.getMostRecentSearch(),
           let index = history.firstIndex(of: recent) {
            history.remove(at: index)
        }
        return history
    }

    /// Returns the most recent search entry if available.
    ///
    /// - Returns: The last stored search or `nil` if none exists.
    /// - Throws: Rethrows persistence errors.
    func recentSearch() throws -> SearchElementModel? {
        try localService.getMostRecentSearch()
    }

    /// Searches images for a query with optional pagination and cache controls.
    ///
    /// Behavior:
    /// - If `isPaginating == false` and a cached entry exists and `forceRefresh == false`,
    ///   returns cached items without a network call.
    /// - Otherwise, fetches the `nextPage` for the query, updates cache, and returns
    ///   **only the newly fetched items**.
    ///
    /// - Parameters:
    ///   - query: Search string used as cache key.
    ///   - isPaginating: `true` to request subsequent pages; `false` for first page.
    ///   - forceRefresh: When `true`, ignores first-page cache and forces a fetch.
    /// - Returns: Newly fetched `ImageAsset` items for the requested page.
    /// - Throws: Network or decoding errors from the underlying service.
    func searchImages(
        query: String,
        isPaginating: Bool,
        forceRefresh: Bool = false
    ) async throws -> [ImageAsset] {
        if !isPaginating,
           let cached = imageCache[query],
           !forceRefresh {
            logManager.trackEvent(event: Event.returnCached(query: query))
            return cached.items
        }

        let nextPage = imageCache[query]?.nextPage ?? 1
        logManager.trackEvent(event: Event.start(query: query, page: nextPage))

        do {
            let response = try await service.searchImages(query: query, page: nextPage, perPage: ImageConstants.perPage)
            let newItems = response.items
            var updatedItems = imageCache[query]?.items ?? []
            updatedItems.append(contentsOf: newItems)

            let hasFullPage = newItems.count == ImageConstants.perPage
            let hasNextPage = response.page.hasNext

            let updatedNextPage = (hasFullPage && hasNextPage) ? nextPage + 1 : nextPage

            imageCache[query] = (items: updatedItems, nextPage: updatedNextPage)

            logManager.trackEvent(event: Event.success(query: query, page: nextPage))
            return newItems
        } catch {
            logManager.trackEvent(event: Event.fail(query: query, page: nextPage))
            throw error
        }
    }
}

/// Internal logging events emitted by `ImageSearchManager`.
///
/// Events encode the lifecycle of a search request and cache hits.
private enum Event: LoggableEvent {
    case start(query: String, page: Int)
    case success(query: String, page: Int)
    case fail(query: String, page: Int)
    case returnCached(query: String)

    /// Canonical event names used by logger backends.
    var eventName: String {
        switch self {
        case .start: return "ImageSearchManager.searchImages.start"
        case .success: return "ImageSearchManager.searchImages.success"
        case .fail: return "ImageSearchManager.searchImages.fail"
        case .returnCached: return "ImageSearchManager.searchImages.returnCached"
        }
    }

    /// Key-value parameters attached to each event for analytics.
    var parameters: [String: Any]? {
        switch self {
        case let .start(query, page):
            return ["query": query, "page": "\(page)"]
        case let .success(query, page):
            return ["query": query, "page": "\(page)"]
        case let .fail(query, page):
            return ["query": query, "page": "\(page)"]
        case let .returnCached(query):
            return ["query": query]
        }
    }

    /// Log severity / channel for the event.
    var type: LogType {
        switch self {
        case .fail: .severe
        default: .analytic
        }
    }
}
