//
//  SwiftDataLocalSearchHistoryPersistence.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10.
//

import SwiftData
import SwiftUI
import Utilities

/// A default `SearchElementEntity` instance used for preloading.
///
/// This is primarily used during the app's first launch to populate the database
/// with a default search item so that the search history has meaningful initial content.
/// The current default value uses the title `"dog"`.
extension SearchElementEntity {
    static let defaultSearchText = "dog"
    static var defaultValue: SearchElementEntity {
        .init(from: .init(title: defaultSearchText))
    }
}

/// A SwiftData container setup for managing `SearchElementEntity` records.
///
/// This container is configured to:
/// - Initialize the underlying `ModelContainer` with the `SearchElementEntity` schema.
/// - Detect if the application is being launched for the first time (via `isFirstTimeLaunch`).
/// - If it is the first launch, preload the database with `SearchElementEntity.defaultValue`
///   so that the user starts with an initial example in the search history.
///
/// The `isFirstTimeLaunch` flag is persisted using the `@UserDefault` property wrapper
/// to ensure this preloading happens only once across app launches.
actor SearchElementContainer {
    @UserDefault(key: "isFirstTimeLaunch", startingValue: true)
    private static var isFirstTimeLaunch: Bool

    /// Creates and configures a `ModelContainer` for search history persistence.
    ///
    /// - Returns: A fully initialized `ModelContainer` with optional preloaded data
    ///   if the app is being launched for the first time.
    @MainActor
    static func create() -> ModelContainer {
        let schema = Schema([SearchElementEntity.self])
        let configuration = ModelConfiguration()
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        if isFirstTimeLaunch {
            isFirstTimeLaunch = false
            container.mainContext.insert(SearchElementEntity.defaultValue)
        }

        return container
    }
}

@MainActor
struct SwiftDataLocalSearchHistoryPersistence: LocalSearchHistoryPersistence {

    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        self.container = SearchElementContainer.create()
    }

    func addRecentSearch(search: SearchElementModel) throws {
        let entity = SearchElementEntity(from: search)
        mainContext.insert(entity)
        /// Persists the recent search to the local SwiftData store.
        /// - Parameter search: The search model to be stored.
        /// - Throws: An error if saving to the SwiftData context fails.
        /// - SeeAlso: [Flickr API - flickr.photos.search](https://www.flickr.com/services/api/flickr.photos.search.html)
        try mainContext.save()
    }

    /// Retrieves the user's recent search history from persistent storage.
    ///
    /// The results are sorted by `dateCreated` in descending order (most recent first)
    /// and filtered to ensure each `title` appears only once (first occurrence kept).
    ///
    /// In the future, the implementation should handle and replace an existing `SearchElement` when adding a new one with the same title.
    ///
    /// - Returns: An array of unique `SearchElementModel` items ordered from most recent to oldest.
    /// - Throws: Rethrows any Core Data fetch errors from `mainContext`.
    func getSearchHistory() throws -> [SearchElementModel] {
        let descriptor = FetchDescriptor<SearchElementEntity>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        let entities = try mainContext.fetch(descriptor)

        var seen = Set<String>()
        return entities.compactMap { entity in
            guard seen.insert(entity.title).inserted else { return nil }
            return entity.toModel()
        }
    }

    /// Retrieves the single most recent search entry from persistent storage.
    ///
    /// The search is determined by the highest `dateCreated` value.
    /// If the stored entry has an empty `title`, it is ignored.
    ///
    /// - Returns: The most recent `SearchElementModel` if available and valid; otherwise `nil`.
    /// - Throws: Rethrows any Core Data fetch errors from `mainContext`.
    func getMostRecentSearch() throws -> SearchElementModel {
        var descriptor = FetchDescriptor<SearchElementEntity>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let entities = try mainContext.fetch(descriptor)
        let model = entities.first ?? .defaultValue
        return model.toModel()
    }
}
