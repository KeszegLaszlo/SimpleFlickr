//
//  MockLocalSearchHistoryPersistence.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10.
//

import Foundation

@MainActor
struct MockLocalSearchHistoryPersistence: LocalSearchHistoryPersistence {
    var history: [SearchElementModel]
    var mostRecent: SearchElementModel?

    init(
        history: [SearchElementModel] = [],
        mostRecent: SearchElementModel? = nil
    ) {
        self.history = history
        self.mostRecent = mostRecent
    }

    func addRecentSearch(search: SearchElementModel) throws { }
    func getSearchHistory() throws -> [SearchElementModel] {
        let sorted = history.sorted { $0.dateCreated > $1.dateCreated }
        var seen = Set<String>()
        return sorted.compactMap { model in
            guard seen.insert(model.title).inserted else { return nil }
            return model
        }
    }
    func getMostRecentSearch() throws -> SearchElementModel {
        guard let mostRecent else { return .init(title: "dog") }
        return mostRecent
    }
}
