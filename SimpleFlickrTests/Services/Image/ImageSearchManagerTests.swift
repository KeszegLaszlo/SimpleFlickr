//
//  ImageSearchManagerTests.swift
//  SimpleFlickrTests
//
//  Created by Keszeg László on 2025.08.11.
//

import CustomNetworking
import Foundation
import Testing
@testable import SimpleFlickr_Dev

@MainActor
struct ImageSearchManagerTests {
    private let mockApiClient = MockApiService()

    @Test("Returns cached items on non-paginating request")
    func returnsCachedItemsOnNonPaginatingRequest() async throws {
        let service = MockImageSearchService(totalPages: 2, apiClient: mockApiClient)
        let manager = makeManager(service: service)

        // First fetch -> network
        let page1 = try await manager.searchImages(query: "cats", isPaginating: false)
        #expect(page1.count == 20)
        #expect(service.callCount == 1)

        // Second fetch (same query, not paginating, no force) -> cache
        let cached = try await manager.searchImages(query: "cats", isPaginating: false)
        #expect(cached == page1)
        #expect(service.callCount == 1) // no extra call
    }

    @Test("Pagination fetches next page and accumulates cache")
    func paginatingFetchesNextPageAndAccumulates() async throws {
        let service = MockImageSearchService(totalPages: 2, apiClient: mockApiClient)
        let manager = makeManager(service: service)

        // Page 1
        let page1 = try await manager.searchImages(query: "dogs", isPaginating: false)
        #expect(page1.count == 20)
        #expect(service.received.last?.page == 1)

        // Page 2 (pagination)
        let page2 = try await manager.searchImages(query: "dogs", isPaginating: true)
        #expect(page2.count == 20)
        #expect(service.received.last?.page == 2)
        #expect(service.callCount == 2)

        // Non-paginating fetch now returns accumulated cache (40)
        let all = try await manager.searchImages(query: "dogs", isPaginating: false)
        #expect(all.count == 40)
        // Ensure accumulation really happened: last 20 should equal p2
        #expect(Array(all.suffix(20)) == page2)
    }

    @Test("Force refresh ignores cache and refetches first page")
    func forceRefreshIgnoresCacheAndRefetchesFirstPage() async throws {
        let service = MockImageSearchService(totalPages: 2, apiClient: mockApiClient)
        let manager = makeManager(service: service)

        let first = try await manager.searchImages(query: "paris", isPaginating: false)
        #expect(service.callCount == 1)

        // Force refresh -> should refetch page 1 (service versions differ)
        let refreshed = try await manager.searchImages(query: "paris", isPaginating: false, forceRefresh: true)
        #expect(service.callCount == 2)
        #expect(refreshed != first) // distinct version proves network fetch

        // After refresh, another non-paginating call should return the refreshed cache
        let cached = try await manager.searchImages(query: "paris", isPaginating: false)
        #expect(cached == refreshed)
    }

    @Test("When no next page, further pagination yields empty array")
    func whenNoNextPageFurtherPaginationYieldsEmpty() async throws {
        // totalPages = 1 -> page 1 only, then hasNext = false
        let service = MockImageSearchService(totalPages: 1, apiClient: mockApiClient)
        let manager = makeManager(service: service)

        _ = try await manager.searchImages(query: "rome", isPaginating: false) // page 1
        let next = try await manager.searchImages(query: "rome", isPaginating: true) // should be empty
        #expect(next.isEmpty)
        #expect(service.callCount == 1) // no page 2 call happened
    }

    @Test("Logs start, success and cache events")
    func logsStartSuccessAndCacheEvents() async throws {
        let logSpy = MockLogService()
        let service = MockImageSearchService(totalPages: 2, apiClient: mockApiClient)
        let manager = makeManager(service: service, logService: logSpy)

        _ = try await manager.searchImages(query: "nyc", isPaginating: false)
        _ = try await manager.searchImages(query: "nyc", isPaginating: false) // cached

        // Expect 3 events: start, success, returnCached
        #expect(logSpy.trackedEvents.count == 3)
        #expect(logSpy.trackedEvents[0].eventName.contains("start"))
        #expect(logSpy.trackedEvents[1].eventName.contains("success"))
        #expect(logSpy.trackedEvents[2].eventName.contains("returnCached"))
    }

    @Test("Logs fail on error and propagates exception")
    func logsFailOnErrorAndPropagates() async {
        let logSpy = MockLogService()
        let service = MockImageSearchService(
            totalPages: 2,
            failingPages: [1],
            apiClient: mockApiClient
        )
        let manager = makeManager(service: service, logService: logSpy)

        do {
            _ = try await manager.searchImages(query: "fail", isPaginating: false)
            #expect(Bool(false)) // should not reach
        } catch {
            // expected
        }

        // Expect 2 events: start, fail
        #expect(logSpy.trackedEvents.count == 2)
        #expect(logSpy.trackedEvents[0].eventName.contains("start"))
        #expect(logSpy.trackedEvents[1].eventName.contains("fail"))
    }

    @Test("History excludes most recent entry")
    func historyExcludesMostRecent() throws {
        let testA = SearchElementModel(title: "testA")
        let testB = SearchElementModel(title: "testB")
        let testC = SearchElementModel(title: "testC")
        let history = MockLocalSearchHistoryPersistence(history: [testA, testB, testC], mostRecent: testB)

        // Service not used in these calls
        let manager = makeManager(
            service: MockImageSearchService(apiClient: mockApiClient),
            history: history
        )

        let list = try manager.getSearchHistory()
        #expect(list.count == 2)
        #expect(list.contains(testA) && list.contains(testC))
        #expect(list.contains(testB) == false)

        let recent = try manager.recentSearch()
        #expect(recent == testB)
    }

    // MARK: - Helpers

    private func makeManager(
        service: ImageSearchService,
        history: MockLocalSearchHistoryPersistence? = nil,
        logService: MockLogService = .init()
    ) -> ImageSearchManager {
        let logger = LogManager(services: [logService])
        // Create the default history INSIDE the function (on MainActor),
        // so we don't call a MainActor-isolated init in a nonisolated context.
        let localHistory = history ?? MockLocalSearchHistoryPersistence(
            history: [],
            mostRecent: nil
        )
        return ImageSearchManager(
            service: service,
            localService: localHistory,
            logManager: logger
        )
    }
}
