//
//  MockImageFetcher.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation

class MockImageSearchService: ImageSearchService {
    var apiClient: any ApiProtocol

    /// How many total pages to expose (>=1). When `1`, there is no next page.
    private let totalPages: Int
    /// Controls simulated failures by page number.
    private let failingPages: Set<Int>

    private(set) var callCount = 0
    private(set) var received: [(query: String, page: Int, perPage: Int)] = []

    /// Each successful call bumps the `version` so returned titles/ids differ across fetches
    /// allowing us to assert cache-vs-network behavior.
    private var version: Int = 0

    init(
        totalPages: Int = 3,
        failingPages: Set<Int> = [],
        apiClient: any ApiProtocol
    ) {
        self.totalPages = max(1, totalPages)
        self.failingPages = failingPages
        self.apiClient = apiClient
    }

    func searchImages(
        query: String,
        page: Int,
        perPage: Int
    ) async throws -> SearchResponse<ImageAsset> {
        callCount += 1
        received.append((query, page, perPage))

        if failingPages.contains(page) {
            throw URLError(.badServerResponse)
        }

        version += 1

        let start = (page - 1) * perPage
        let items: [ImageAsset] = (0..<perPage).compactMap { idx in
            let id = "test-\(query)-p\(page)-v\(version)-#\(start + idx)"
            guard let thumb = URL(string: "https://example.com/thumb/\(id)"),
                  let full  = URL(string: "https://example.com/full/\(id)") else { return nil }
            return ImageAsset(
                id: id,
                title: id,
                thumbnail: thumb,
                original: full,
                size: .init(width: 1000, height: 800),
                source: .mock
            )
        }

        let hasNext = page < totalPages
        let pageMeta = Page(page: page, perPage: perPage, total: perPage * totalPages, pages: totalPages)
        return SearchResponse(items: items, page: pageMeta.with(hasNext: hasNext))
    }
}

private extension Page {
    /// Convenience to override `hasNext` without changing other values.
    func with(hasNext: Bool) -> Page {
        Page(
            page: self.page,
            perPage: self.perPage,
            total: self.total,
            pages: self.pages
        )
    }
}
