//
//  SwiftDataLocalAvatarPersistence.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10..
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

    func addRecentSearch(seach: SearchElementModel) throws {
        let entity = SearchElementEntity(from: seach)
        mainContext.insert(entity)
        /// Persists the recent search to the local SwiftData store.
        /// - Parameter seach: The search model to be stored.
        /// - Throws: An error if saving to the SwiftData context fails.
        /// - SeeAlso: [Flickr API - flickr.photos.search](https://www.flickr.com/services/api/flickr.photos.search.html)
        try mainContext.save()
    }

    func getSearchHistory() throws -> [SearchElementModel] {
        let descriptor = FetchDescriptor<SearchElementEntity>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
        let entities = try mainContext.fetch(descriptor)
        return entities.map { $0.toModel() }
    }
    
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
