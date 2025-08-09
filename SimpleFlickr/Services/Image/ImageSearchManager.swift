//
//  ImageFetcherManager.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import Logger

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

    init(
        service: any ImageSearchService,
        localService: any LocalSearchHistoryPersistence,
        logManager: LogManager
    ) {
        self.service = service
        self.localService = localService
        self.logManager = logManager
    }

    func addRecentSearch(seach: SearchElementModel) throws {
        try localService.addRecentSearch(seach: seach)
    }

    func getSearchHistory() throws -> [SearchElementModel] {
        try localService.getSearchHistory()
    }

    func recentSearch() throws -> SearchElementModel? {
        try localService.getMostRecentSearch()
    }

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

    func invalidateCache(for query: String) {
        imageCache.removeValue(forKey: query)
    }

    func cleanup() {
        imageCache.removeAll()
    }
}

private enum Event: LoggableEvent {
    case start(query: String, page: Int)
    case success(query: String, page: Int)
    case fail(query: String, page: Int)
    case returnCached(query: String)

    var eventName: String {
        switch self {
        case .start: return "ImageSearchManager.searchImages.start"
        case .success: return "ImageSearchManager.searchImages.success"
        case .fail: return "ImageSearchManager.searchImages.fail"
        case .returnCached: return "ImageSearchManager.searchImages.returnCached"
        }
    }

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

    var type: LogType {
        switch self {
        case .fail: .severe
        default: .analytic
        }
    }
}
