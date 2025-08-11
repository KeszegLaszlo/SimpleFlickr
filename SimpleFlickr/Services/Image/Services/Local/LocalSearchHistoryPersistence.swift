//
//  LocalSearchHistoryPersistence.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10.
//

@MainActor
protocol LocalSearchHistoryPersistence {
    func addRecentSearch(search: SearchElementModel) throws
    func getSearchHistory() throws -> [SearchElementModel]
    func getMostRecentSearch() throws -> SearchElementModel
}
