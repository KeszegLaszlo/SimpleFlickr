//
//  ImageListInteractor.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation

@MainActor
protocol ImageListInteractor {
    func loadImages(
        query: String,
        isPaginating: Bool,
        forceRefresh: Bool
    ) async throws -> [ImageAsset]

    func addRecentSearch(search: SearchElementModel) throws
    func getSearchHistory() throws -> [SearchElementModel]
    func getMostRecentSearch() throws -> SearchElementModel
    func trackScreenEvent(event: LoggableEvent)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ImageListInteractor { }
