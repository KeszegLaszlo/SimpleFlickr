//
//  MockLocalSearchHistoryPersistence.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10.
//

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
    func getSearchHistory() throws -> [SearchElementModel] { history }
    func getMostRecentSearch() throws -> SearchElementModel? { mostRecent }
}
