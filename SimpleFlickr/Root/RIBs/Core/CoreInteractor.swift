//
//  CoreInteractor.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

@MainActor
struct CoreInteractor {
    private let logManager: LogManager
    private let imageSearchManager: ImageSearchManager

    init(container: DependencyContainer) {
        self.logManager = container.resolve(LogManager.self)!
        let imageSearchService = container.resolve(ImageSearchService.self)!
        self.imageSearchManager = ImageSearchManager(service: imageSearchService, logManager: logManager)
    }

    func getInitialMessages(
        query: String,
        isPaginating: Bool,
        forceRefresh: Bool = false
    ) async throws -> [ImageAsset] {
        try await imageSearchManager.searchImages(
            query: query,
            isPaginating: isPaginating,
            forceRefresh: false
        )
    }

    func loadMoreImages(
        query: String,
        isPaginating: Bool,
        forceRefresh: Bool = false
    ) async throws -> [ImageAsset] {
        try await imageSearchManager.searchImages(
            query: query,
            isPaginating: isPaginating,
            forceRefresh: true
        )
    }
}
