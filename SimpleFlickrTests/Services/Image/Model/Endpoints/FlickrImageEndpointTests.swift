//
//  ImageAssetTests.swift
//  SimpleFlickrTests
//
//  Created by Keszeg László on 2025.08.11.
//

import Foundation
import Testing
@testable import SimpleFlickr_Dev

struct FlickrImageEndpointTests {

    @Test("Defaults and static config")
    func testDefaults() {
        let endpoint: FlickrImageEndpoint = .search(query: "kittens", page: 1, perPage: 20)

        #expect(endpoint.scheme == "https")
        #expect(endpoint.baseURL == "api.flickr.com")
        #expect(endpoint.port == nil)
        #expect(endpoint.apiKeyHeaderField == nil)
        #expect(endpoint.apiKeyQueryName == "api_key")
        #expect(endpoint.body == nil)
        #expect(endpoint.mockFile == nil)
    }

    @Test("Path and HTTP method for search")
    func testPathAndMethod() {
        let endpoint: FlickrImageEndpoint = .search(query: "sunsets", page: 2, perPage: 50)
        #expect(endpoint.path == "/services/rest")
        #expect(endpoint.method == .get)
    }

    @Test("Query items for search")
    func testQueryItemsForSearch() {
        let query = "mountains"
        let page = 3
        let per = 99
        let endpoint: FlickrImageEndpoint = .search(query: query, page: page, perPage: per)
        let items = endpoint.queryItems

        #expect(value("method", in: items) == "flickr.photos.search")
        #expect(value("text", in: items) == query)
        #expect(value("page", in: items) == String(page))
        #expect(value("per_page", in: items) == String(per))
        #expect(value("format", in: items) == "json")
        #expect(value("nojsoncallback", in: items) == "1")
        #expect(value("extras", in: items) == "url_q,url_o,o_dims")
    }

    @Test("API key injection via static var")
    func testAPIKeyInjection() {
        let key = "TEST-KEY-123"
        FlickrImageEndpoint.injectedAPIKey = key
        defer { FlickrImageEndpoint.injectedAPIKey = nil }

        let endpoint: FlickrImageEndpoint = .search(query: "flowers", page: 1, perPage: 10)
        #expect(endpoint.apiKey == key)
        #expect(endpoint.apiKeyQueryName == "api_key")
    }

    // MARK: - Helpers
    private func value(_ name: String, in items: [URLQueryItem]?) -> String? {
        items?.first(where: { $0.name == name })?.value
    }
}
