//
//  SwiftDataLocalSearchHistoryPersistence.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10.
//

import SwiftData
import SwiftUI

@MainActor
struct SwiftDataLocalSearchHistoryPersistence: LocalSearchHistoryPersistence {
    private let container: ModelContainer
    
    private var mainContext: ModelContext {
        container.mainContext
    }
    
    init() {
        // swiftlint:disable:next force_try
        self.container = try! ModelContainer(for: SearchElementEntity.self)
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
    func getMostRecentSearch() throws -> SearchElementModel? {
        var descriptor = FetchDescriptor<SearchElementEntity>(
            sortBy: [SortDescriptor(\.dateCreated, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let entities = try mainContext.fetch(descriptor)
        if let model = entities.first?.toModel(),
           !model.title.isEmpty {
            return model
        } else {
            return nil
        }
    }
}
