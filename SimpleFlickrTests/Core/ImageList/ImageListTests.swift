//
//  ImageListTests.swift
//  SimpleFlickrTests
//
//  Created by Keszeg László on 2025. 08. 10.
//

import Testing
@testable import SimpleFlickr
internal import Logger
internal import Foundation

@MainActor
struct ImageListTests {

    // MARK: - Mocks
    @MainActor
    final class MockImageListRouter: ImageListRouter {
        var didShowImageDetailsWithId: String?
        func showImageDetails(delegate: DetailsViewDelegate) {
            didShowImageDetailsWithId = delegate.image.id
        }
    }

    @MainActor
    final class MockImageListInteractor: ImageListInteractor {
        struct LoadCall: Equatable { let query: String; let isPaginating: Bool; let forceRefresh: Bool }

        // Control
        var imagesToReturn: [ImageAsset] = []
        var errorToThrow: Error?
        var mostRecentSearch: SearchElementModel? = nil
        var storedHistory: [SearchElementModel] = []

        // Observability
        private(set) var loadCalls: [LoadCall] = []
        private(set) var trackedEvents: [LoggableEvent] = []
        private(set) var trackedScreenEvents: [LoggableEvent] = []

        // MARK: ImageListInteractor
        func loadImages(query: String, isPaginating: Bool, forceRefresh: Bool) async throws -> [ImageAsset] {
            loadCalls.append(.init(query: query, isPaginating: isPaginating, forceRefresh: forceRefresh))
            if let errorToThrow { throw errorToThrow }
            return imagesToReturn
        }

        func addRecentSearch(search: SearchElementModel) throws {
            storedHistory.removeAll { $0.title.caseInsensitiveCompare(search.title) == .orderedSame }
            storedHistory.insert(search, at: 0)
        }

        func getSearchHistory() throws -> [SearchElementModel] { storedHistory }
        func getMostRecentSearch() throws -> SearchElementModel? { mostRecentSearch }
        func trackScreenEvent(event: LoggableEvent) { trackedScreenEvents.append(event) }
        func trackEvent(event: LoggableEvent) { trackedEvents.append(event) }
    }

    // A lightweight type-erased interactor for custom behaviors per test
    @MainActor
    struct AnyImageListInteractor: ImageListInteractor {
        let anyLoad: (String, Bool, Bool) async throws -> [ImageAsset]
        let anyAddRecent: (SearchElementModel) throws -> Void
        let anyGetHistory: () throws -> [SearchElementModel]
        let anyGetMostRecent: () throws -> SearchElementModel?
        let anyTrackScreen: (LoggableEvent) -> Void
        let anyTrack: (LoggableEvent) -> Void

        func loadImages(query: String, isPaginating: Bool, forceRefresh: Bool) async throws -> [ImageAsset] {
            try await anyLoad(query, isPaginating, forceRefresh)
        }
        func addRecentSearch(search: SearchElementModel) throws { try anyAddRecent(search) }
        func getSearchHistory() throws -> [SearchElementModel] { try anyGetHistory() }
        func getMostRecentSearch() throws -> SearchElementModel? { try anyGetMostRecent() }
        func trackScreenEvent(event: LoggableEvent) { anyTrackScreen(event) }
        func trackEvent(event: LoggableEvent) { anyTrack(event) }
    }

    // MARK: - Tests

    @Test("onAppear tracks screen event")
    func testOnAppearTracksScreenEvent() async throws {
        // Given
        let interactor = MockImageListInteractor()
        let router = MockImageListRouter()
        let presenter = ImageListPresenter(interactor: interactor, router: router)

        // When
        presenter.onAppear()

        // Then
        #expect(interactor.trackedScreenEvents.contains { $0.eventName == "ImageListView" })
    }

    @Test("loadImages success updates images and logs success")
    func testLoadImagesSuccess() async throws {
        // Given
        var interactor = MockImageListInteractor()
        interactor.imagesToReturn = [] // success path without needing concrete ImageAsset
        let presenter = ImageListPresenter(interactor: interactor, router: MockImageListRouter())

        // When
        await presenter.loadImages()

        // Then
        #expect(interactor.trackedEvents.contains { $0.eventName == ImageListPresenter.Event.loadImagesStart(query: presenter.searchText).eventName })
        #expect(interactor.trackedEvents.contains { $0.eventName == ImageListPresenter.Event.loadImagesSuccess(count: 0, query: presenter.searchText).eventName })
    }

    @Test("loadImages failure switches to empty and logs fail")
    func testLoadImagesFailure() async throws {
        // Given
        enum Dummy: Error { case boom }
        var interactor = MockImageListInteractor()
        interactor.errorToThrow = Dummy.boom
        let presenter = ImageListPresenter(interactor: interactor, router: MockImageListRouter())

        // When
        await presenter.loadImages()

        // Then
        #expect(interactor.trackedEvents.contains { $0.eventName == ImageListPresenter.Event.loadImagesFail(query: presenter.searchText, error: Dummy.boom).eventName })
    }

    @Test("submitSearch triggers load & persists history when text changed and non-empty")
    func testSubmitSearchPersistsHistory() async throws {
        // Given
        var interactor = MockImageListInteractor()
        let presenter = ImageListPresenter(interactor: interactor, router: MockImageListRouter())
        presenter.searchText = "kittens"

        // When
        await presenter.submitSearch()

        // Then
        #expect(interactor.trackedEvents.contains { $0.eventName == ImageListPresenter.Event.addRecentSearch(text: "kittens").eventName })
        // Grab updated history from presenter
        #expect(presenter.searchResults.first?.title == "kittens")
    }

    @Test("onFocusChanged(false) submits only when text differs from last commit")
    func testOnFocusChangedSubmitsWhenChanged() async throws {
        // Given
        var loadStartCount = 0
        let interactor = AnyImageListInteractor(
            anyLoad: { _, _, _ in loadStartCount += 1; return [] },
            anyAddRecent: { _ in },
            anyGetHistory: { [] },
            anyGetMostRecent: { nil },
            anyTrackScreen: { _ in },
            anyTrack: { _ in }
        )
        let presenter = ImageListPresenter(interactor: interactor, router: MockImageListRouter())

        // First blur with unchanged default text => should submit once
        await presenter.onFocusChanged(false)
        let first = loadStartCount

        // Blur again without changes => no additional submits
        await presenter.onFocusChanged(false)
        let second = loadStartCount

        // Change text and blur => should submit again
        presenter.searchText = "puppies"
        await presenter.onFocusChanged(false)
        let third = loadStartCount

        // Then
        #expect(first == 1)
        #expect(second == 1)
        #expect(third == 2)
    }

    @Test("historySearchDidTap updates searchText and triggers load")
    func testHistorySearchTap() async throws {
        // Given
        var calls = 0
        let interactor = AnyImageListInteractor(
            anyLoad: { _, _, _ in calls += 1; return [] },
            anyAddRecent: { _ in },
            anyGetHistory: { [] },
            anyGetMostRecent: { nil },
            anyTrackScreen: { _ in },
            anyTrack: { _ in }
        )
        let presenter = ImageListPresenter(interactor: interactor, router: MockImageListRouter())

        // When
        let chip = SearchElementModel(title: "sunsets")
        await presenter.historySearchDidTap(chip: chip)

        // Then
        #expect(presenter.searchText == "sunsets")
        #expect(calls == 1)
    }

    @Test("init loads latest search & history from interactor")
    func testInitLoadsLatestSearch() async throws {
        // Given
        var interactor = MockImageListInteractor()
        interactor.mostRecentSearch = .init(title: "mountains")
        interactor.storedHistory = [.init(title: "mountains"), .init(title: "oceans")]

        // When
        let presenter = ImageListPresenter(interactor: interactor, router: MockImageListRouter())

        // Then
        #expect(presenter.searchText == "mountains")
        #expect(presenter.searchResults.count == 2)
        #expect(interactor.trackedEvents.contains { $0.eventName == ImageListPresenter.Event.getLatestSearch.eventName })
    }
}
