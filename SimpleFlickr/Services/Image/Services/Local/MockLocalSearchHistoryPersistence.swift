//
//  MockLocalSearchHistoryPersistence.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10.
//

@MainActor
struct MockLocalSearchHistoryPersistence: LocalSearchHistoryPersistence {
    let history: [SearchElementModel]

    init(history: [SearchElementModel] = SearchElementModel.mocks) {
        self.history = history
    }

    func addRecentSearch(search: SearchElementModel) throws { }

    func getSearchHistory() throws -> [SearchElementModel] {
        history
    }

    func getMostRecentSearch() throws -> SearchElementModel? {
        nil
    }
}
