//
//  MockImageFetcher.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation

struct MockImageSearchService: ImageSearchService {
    private let delay: Double
    private let showError: Bool
    let apiClient: any ApiProtocol

    init(
        delay: Double = 0.0,
        showError: Bool = false,
        apiClient: any ApiProtocol
    ) {
        self.delay = delay
        self.showError = showError
        self.apiClient = apiClient
    }

    func searchImages(
        query: String,
        page: Int,
        perPage: Int
    ) async throws -> SearchResponse<ImageAsset> {
        let start = (page - 1) * perPage
        let items = (0..<perPage).compactMap { idx -> ImageAsset? in
            let id = "mock-\(start + idx)"
            guard let thumb = URL(string: "https://picsum.photos/seed/\(id)/200"),
                  let full = URL(string: "https://picsum.photos/seed/\(id)/1200")
            else { return nil }

            return ImageAsset(
                id: id,
                title: "\(query) #\(start + idx)",
                thumbnail: thumb,
                original: full,
                size: .init(width: 1200, height: 800),
                source: .mock
            )
        }

        let pageMeta = Page(page: page, perPage: perPage, total: 10_000, pages: 10_000 / max(perPage, 1))
        return SearchResponse(items: items, page: pageMeta)
    }

    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
}
