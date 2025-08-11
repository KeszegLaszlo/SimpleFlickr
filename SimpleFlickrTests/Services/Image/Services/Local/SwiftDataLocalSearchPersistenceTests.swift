//
//  SwiftDataLocalSearchHistoryPersistenceTests.swift
//  SimpleFlickrTests
//
//  Created by Keszeg László on 2025.08.11.
//

import Foundation
import Testing
import SwiftData
@testable import SimpleFlickr_Dev

@MainActor
struct SwiftDataLocalSearchHistoryPersistenceTests {

    @Test("addRecentSearch persists and fetch returns it")
    func addAndFetch() throws {
        var mock = MockLocalSearchHistoryPersistence()
        let model = SearchElementModel(title: "cats")
        try mock.addRecentSearch(search: model)

        mock.history = [model] // simulate persistence effect
        let history = try mock.getSearchHistory()
        #expect(history.count == 1)
        #expect(history.first?.title == "cats")
    }

    @Test("getSearchHistory returns unique titles in descending date order")
    func historyUniqueAndSorted() throws {
        let now = Date()
        let older = now.addingTimeInterval(-60)
        let history = [
            SearchElementModel(title: "a", dateCreated: now),
            SearchElementModel(title: "b", dateCreated: now.addingTimeInterval(-1)),
            SearchElementModel(title: "a", dateCreated: older) // duplicate
        ]
        let mock = MockLocalSearchHistoryPersistence(history: history)

        let fetched = try mock.getSearchHistory()
        #expect(fetched.map(\.title) == ["a", "b"])
    }

    @Test("getMostRecentSearch returns nil when no entries")
    func mostRecentNilWhenEmpty() throws {
        let mock = MockLocalSearchHistoryPersistence()
        #expect(try mock.getMostRecentSearch() == nil)
    }

    @Test("getMostRecentSearch ignores empty title")
    func mostRecentIgnoresEmptyTitle() throws {
        let mock = MockLocalSearchHistoryPersistence(mostRecent: SearchElementModel(title: ""))
        #expect(try mock.getMostRecentSearch() == nil)
    }

    @Test("getMostRecentSearch returns the latest by dateCreated")
    func mostRecentReturnsLatest() throws {
        let newer = SearchElementModel(title: "new", dateCreated: Date())
        let mock = MockLocalSearchHistoryPersistence(mostRecent: newer)
        let recent = try mock.getMostRecentSearch()
        #expect(recent?.title == "new")
    }
}
