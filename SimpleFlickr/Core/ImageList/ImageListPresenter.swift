//
//  ImageListPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Observation
import SwiftUI
import Logger
import Utilities
import CoreMotion

/// # Overview
/// `ImageListPresenter` manages the image list screen state, user interactions, and navigation.
///
/// ## Responsibilities
/// - Coordinates with an `ImageListInteractor` to fetch data.
/// - Drives navigation through an `ImageListRouter`.
/// - Tracks analytics and error events via `Logger`.
/// - Orchestrates search submission and pagination.
///
/// ## Concurrency
/// Uses Swift Concurrency (`Task`) for request lifecycles and cancels in-flight tasks when superseded to avoid duplicate work and stale UI updates.
/// All UI-facing mutations are performed on the main actor.
@Observable
@MainActor
class ImageListPresenter {
    private enum Constants {
        static let defaultSearchText = "dog"
    }

    private let interactor: any ImageListInteractor
    private let router: any ImageListRouter

    /// The images currently shown in the list, updated after each successful fetch.
    private(set) var images = [ImageAsset]()
    /// Recent searches loaded from persistence and updated after each committed search.
    private(set) var searchResults = [SearchElementModel]()
    /// Indicates whether a pagination request is in progress.
    /// The value toggles with animation for subtle UI feedback.
    private(set) var isLoadingMore = false
    /// The current high-level view state (loading, loaded, or empty) driving the UI.
    private(set) var viewState: ImageListView.ViewState = .loading
    // Should keep the last selected in AppStorage
    /// The active grid/list layout identifier used by the view to switch layouts.
    private(set) var layyoutId = Int.random(in: 1...3)

    private var lastCommittedSearchText = ""
    private(set) var showLayoutSelector = false

    var pitch: Double = .zero
    var roll: Double = .zero
    var rotation: Double = .zero
    private let motion = CMMotionManager()

    /// The current search text. Mutated from the view and consumed by fetch operations.
    var searchText = Constants.defaultSearchText

    /// The reason shown when the view is in the `.empty` state, derived from the current `searchText`.
    private var emptyReason: ImageListView.ViewState.EmptyReason {
        searchText.isEmpty ? .noFetchedResults : .notFoundForString(searchText: searchText)
    }

    /// Creates a presenter.
    ///
    /// - Parameters:
    ///   - interactor: Provides image loading and persistence.
    ///   - router: Handles navigation.
    init(interactor: any ImageListInteractor, router: any ImageListRouter) {
        self.interactor = interactor
        self.router = router
        motion.deviceMotionUpdateInterval = 1/60
        motion.startDeviceMotionUpdates(to: .main) { (motionData, error) in
            guard error == nil else { return }

            if let motionData = motionData {
                self.pitch = motionData.attitude.pitch
                self.roll = motionData.attitude.roll
                self.rotation = motionData.rotationRate.x
            }
        }
        getLatestSearch()
    }

    func updateLayoudId(to id: Int) {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            layyoutId = id
            showLayoutSelector = false
        }
    }

    func toggleLayoutSelector() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            showLayoutSelector.toggle()
        }
    }

    /// Call from the view's `.onAppear` or `.task` to track screen impressions.
    func onAppear() {
        interactor.trackScreenEvent(event: Event.viewAppeared)
    }

    /// Submits the current `searchText` for fetching, regardless of whether it changed.
    ///
    /// Cancels any ongoing load and starts a fresh one, then updates search history.
    func submitSearch() async {
        await submitSearchIfNeeded()
    }

    func historySearchDidTap(chip: SearchElementModel) async {
        searchText = chip.title
        await submitSearchIfNeeded()
    }

    /// Handles text-field focus transitions.
    ///
    /// When focus is lost, submits a search **only** if the trimmed text is non-empty and changed since the last committed search.
    ///
    /// - Parameter focused: Whether the search field is focused.
    func onFocusChanged(_ focused: Bool) async {
        guard !focused else { return }
        await submitSearchIfNeeded()
    }

    /// Handles selection of an image and navigates to its details.
    ///
    /// Also tracks the selection for analytics.
    ///
    /// - Parameter image: The tapped image.
    func onSelectImage(_ image: ImageAsset) {
        interactor.trackEvent(event: Event.selectImage(id: image.id))
        router.showImageDetails(delegate: .init(image: image))
    }

    /// Loads images for the current `searchText`.
    ///
    /// Cancels any previous load, switches the `viewState` to `.loading`, performs the request, and updates `images` and `viewState` accordingly.
    ///
    /// - Note: This call forces a network refresh and bypasses caches.
    func loadImages() async {
        interactor.trackEvent(event: Event.loadImagesStart(query: searchText))
        updateViewStates(to: .loading)
        do {
            let fetchedImages = try await interactor.loadImages(
                query: searchText,
                isPaginating: false,
                forceRefresh: true
            )
            images = fetchedImages
            updateViewStates(to: .loaded)
            interactor.trackEvent(event: Event.loadImagesSuccess(count: fetchedImages.count, query: searchText))
        } catch is CancellationError {
            // Don't update the UI; this is expected
        } catch {
            updateViewStates(to: .empty(emptyReason))
            interactor.trackEvent(event: Event.loadImagesFail(query: searchText, error: error))
        }
    }

    /// Loads the next page when the supplied `image` is currently the last displayed item.
    ///
    /// Safely coalesces concurrent requests and animates `isLoadingMore` for UI feedback.
    ///
    /// - Parameter image: The cell's trailing image that triggered pagination.
    func loadMoreData(image: ImageAsset) {
        let shouldContinue: Bool = image.id == images.last?.id && !isLoadingMore
        guard shouldContinue else { return }
        Task {
            interactor.trackEvent(event: Event.loadMoreStart)
            updateLoadingStatus(to: true)
            defer { updateLoadingStatus(to: false) }
            do {
                let moreImages = try await interactor.loadImages(
                    query: searchText,
                    isPaginating: true,
                    forceRefresh: false
                )
                guard !moreImages.isEmpty else { return }
                await MainActor.run {
                    images.append(contentsOf: moreImages)
                }
                interactor.trackEvent(event: Event.loadMoreSuccess(count: moreImages.count))
            } catch {
                interactor.trackEvent(event: Event.loadMoreFail(error: error))
            }
        }
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    /// Submits a search if the trimmed `searchText` is non-empty and either changed since the last commit or `force` is `true`.
    ///
    /// - Parameter force: When `true`, submits even if the text did not change.
    private func submitSearchIfNeeded() async {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text != lastCommittedSearchText else { return }
        await loadImages()
        addNewSearchToHistory()
        lastCommittedSearchText = text
        dismissKeyboard()
    }

    /// Persists the current `searchText` into recent searches and refreshes `searchResults`.
    private func addNewSearchToHistory() {
        do {
            interactor.trackEvent(event: Event.addRecentSearch(text: searchText))
            let searchModel: SearchElementModel = .init(title: searchText)
            try interactor.addRecentSearch(search: searchModel)
            searchResults = try interactor.getSearchHistory()
        } catch {
            router.showAlert(error: error)
        }
    }

    /// Loads the most recent search from persistence and updates both `searchText` and `searchResults`.
    private func getLatestSearch() {
        interactor.trackEvent(event: Event.getLatestSearch)
        do {
            if let lastSearch = try interactor.getMostRecentSearch() {
                searchText = lastSearch.title
                lastCommittedSearchText = lastSearch.title
            }
            searchResults = try interactor.getSearchHistory()
        } catch {
            router.showAlert(error: error)
        }
    }

    /// Updates `isLoadingMore` with animation.
    ///
    /// - Parameter isLoading: The new loading state.
    private func updateLoadingStatus(to isLoading: Bool) {
        withAnimation {
            isLoadingMore = isLoading
        }
    }

    /// Updates the `viewState` with animation.
    ///
    /// - Parameter viewState: The new state to apply.
    private func updateViewStates(to viewState: ImageListView.ViewState) {
        withAnimation {
            self.viewState = viewState
        }
    }

    /// Analytics and diagnostic events emitted by `ImageListPresenter`.
    enum Event: LoggableEvent {
        case viewAppeared
        case loadImagesStart(query: String)
        case loadImagesSuccess(count: Int, query: String)
        case loadImagesFail(query: String, error: Error)
        case loadMoreStart
        case loadMoreSuccess(count: Int)
        case loadMoreFail(error: Error)
        case selectImage(id: String)
        case addRecentSearch(text: String)
        case getLatestSearch

        var eventName: String {
            switch self {
            case .viewAppeared: "ImageListView"
            case .loadImagesStart: "ImageListPresenter_LoadImages_Start"
            case .loadImagesSuccess: "ImageListPresenter_LoadImages_Success"
            case .loadImagesFail: "ImageListPresenter_LoadImages_Fail"
            case .loadMoreStart: "ImageListPresenter_LoadMore_Start"
            case .loadMoreSuccess: "ImageListPresenter_LoadMore_Success"
            case .loadMoreFail: "ImageListPresenter_LoadMore_Fail"
            case .selectImage: "ImageListPresenter_SelectImage"
            case .addRecentSearch: "ImageListPresenter_AddRecentSearch"
            case .getLatestSearch: "ImageListPresenter_GetLatestSearch"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .loadImagesStart(let query):
                return ["query": query]
            case .loadImagesSuccess(let count, let query):
                return ["count": count, "query": query]
            case .loadImagesFail(let query, let error):
                var params: [String: Any] = ["query": query]
                params["errorDescription"] = String(describing: error)
                return params
            case .loadMoreStart:
                return nil
            case .loadMoreSuccess(let count):
                return ["count": count]
            case .loadMoreFail(let error):
                return ["errorDescription": String(describing: error)]
            case .selectImage(let id):
                return ["id": id]
            case .addRecentSearch(let text):
                return ["text": text]
            case .getLatestSearch:
                return nil
            case .viewAppeared:
                return nil
            }
        }

        var type: LogType {
            switch self {
            case .loadImagesFail, .loadMoreFail: .severe
            default: .analytic
            }
        }
    }
}
