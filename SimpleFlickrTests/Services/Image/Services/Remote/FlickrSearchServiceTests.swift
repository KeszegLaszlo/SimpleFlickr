//
//  FlickrSearchServiceTests.swift
//  SimpleFlickrTests
//
//  Created by Keszeg László on 2025.08.11.
//

import Foundation
import Testing
@testable import SimpleFlickr_Dev

// MARK: - Stub Api Client

struct StubApiClient: ApiProtocol {
    let responseData: Data?
    let error: Error?

    init(responseData: Data) {
        self.responseData = responseData
        self.error = nil
    }

    init(error: Error) {
        self.responseData = nil
        self.error = error
    }

    func asyncRequest<T: Decodable>(
        endpoint: any EndpointProvider
    ) async throws -> T {
        if let error { throw error }
        guard let data = responseData else { fatalError("StubApiClient misconfigured: missing responseData") }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}

// MARK: - Tests

@MainActor
struct FlickrSearchServiceTests {

    @Test("Maps items using extras URLs and original dimensions; returns correct page metadata")
    func mapsUsingExtrasAndPageMeta() async throws {
        let photo = photo(
            id: "42",
            secret: "abcd",
            server: "1234",
            title: "Hello",
            urlQ: "https://cdn.example/thumb.jpg",
            urlO: "https://cdn.example/original.jpg",
            oWidth: "1200",      // as String to test flexible int
            oHeight: 800,         // as Int
            widthQ: 150,
            heightQ: "150"
        )
        let data = makeEnvelopeJSON(page: 2, pages: 5, perpage: 20, total: "100", photos: [photo])
        let api = StubApiClient(responseData: data)
        let sut = FlickrSearchService(apiKey: "k", apiClient: api)

        let resp = try await sut.searchImages(query: "q", page: 2, perPage: 20)
        #expect(resp.items.count == 1)
        let item = try #require(resp.items.first)
        #expect(item.id == "42")
        #expect(item.title == "Hello")
        #expect(item.thumbnail.absoluteString == "https://cdn.example/thumb.jpg")
        #expect(item.original?.absoluteString == "https://cdn.example/original.jpg")
        #expect(item.size?.width == 1200 && item.size?.height == 800)
        #expect(resp.page.page == 2 && resp.page.pages == 5 && resp.page.perPage == 20 && resp.page.total == 100)
    }

    @Test("Builds URLs via fallback when extras are missing")
    func buildsURLsWhenExtrasMissing() async throws {
        // No url_q/url_o provided
        let photo = photo(id: "99", secret: "zzz", server: "sv", title: "X")
        let data = makeEnvelopeJSON(page: 1, pages: 1, perpage: 1, total: 1, photos: [photo])
        let api = StubApiClient(responseData: data)
        let sut = FlickrSearchService(apiKey: "k", apiClient: api)

        let resp = try await sut.searchImages(query: "q", page: 1, perPage: 1)
        let item = try #require(resp.items.first)
        // Thumbnail must exist (constructed q size)
        #expect(item.thumbnail.host == "live.staticflickr.com")
        #expect(item.thumbnail.path.contains("/sv/99_zzz_q.jpg"))
        // Original may be constructed as well (b size)
        #expect(item.original?.path.contains("/sv/99_zzz_b.jpg") == true)
    }

    @Test("Filters out photos without thumbnail URL after mapping")
    func dropsItemsWithoutThumb() async throws {
        // Construct one item that cannot produce a thumbnail (server/id/secret empty -> invalid URL)
        let bad = photo(
            id: "1",
            secret: "",
            server: "",
            title: "bad"
        )
        let good = photo(
            id: "2",
            secret: "sec",
            server: "sv",
            title: "good",
            urlQ: "https://x/y.jpg"
        )
        let data = makeEnvelopeJSON(photos: [bad, good])
        let api = StubApiClient(responseData: data)
        let sut = FlickrSearchService(apiKey: "k", apiClient: api)

        let resp = try await sut.searchImages(query: "q", page: 1, perPage: 20)
        #expect(resp.items.count == 1)
        #expect(resp.items.first?.id == "2")
    }

    @Test("Maps Flickr error (stat=fail) to FlickrServiceError")
    func mapsFlickrErrorOnFailStat() async {
        let data = makeEnvelopeJSON(stat: "fail", code: 100, message: "Invalid API Key", photos: [])
        let api = StubApiClient(responseData: data)
        let sut = FlickrSearchService(apiKey: "k", apiClient: api)

        do {
            _ = try await sut.searchImages(query: "q", page: 1, perPage: 20)
            #expect(Bool(false))
        } catch let error as FlickrServiceError {
            #expect(true)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("Wraps DecodingError as ImageSearchError.decoding")
    func wrapsDecodingError() async {
        // Malformed JSON: missing required fields
        let data = Data("{".utf8)
        let api = StubApiClient(responseData: data)
        let sut = FlickrSearchService(apiKey: "k", apiClient: api)

        do {
            _ = try await sut.searchImages(query: "q", page: 1, perPage: 20)
            #expect(Bool(false))
        } catch let ImageSearchError.decoding(underlying) {
            // ok
            #expect(String(describing: underlying).isEmpty == false)
        } catch {
            #expect(Bool(false))
        }
    }

    @Test("Wraps transport errors as ImageSearchError.transport")
    func wrapsTransportError() async {
        let api = StubApiClient(error: URLError(.timedOut))
        let sut = FlickrSearchService(apiKey: "k", apiClient: api)

        do {
            _ = try await sut.searchImages(query: "q", page: 1, perPage: 20)
            #expect(Bool(false))
        } catch let ImageSearchError.transport(underlying) {
            #expect((underlying as? URLError)?.code == .timedOut)
        } catch {
            #expect(Bool(false))
        }
    }

    // MARK: - JSON Builders

    private func makeEnvelopeJSON(
        stat: String = "ok",
        code: Int? = nil,
        message: String? = nil,
        page: Int = 1,
        pages: Int = 3,
        perpage: Int = 20,
        total: Any = 60, // can be Int or String
        photos: [[String: Any]]
    ) -> Data {
        var root: [String: Any] = [
            "stat": stat,
            "photos": [
                "page": page,
                "pages": pages,
                "perpage": perpage,
                "total": total,
                "photo": photos
            ]
        ]
        if let code { root["code"] = code }
        if let message { root["message"] = message }
        // swiftlint:disable:next force_try
        return try! JSONSerialization.data(withJSONObject: root, options: [])
    }

    private func photo(
        id: String = "1",
        owner: String = "o",
        secret: String = "s",
        server: String = "sv",
        title: String = "t",
        urlQ: String? = nil,
        urlO: String? = nil,
        oWidth: Any? = nil,
        oHeight: Any? = nil,
        widthQ: Any? = nil,
        heightQ: Any? = nil
    ) -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "owner": owner,
            "secret": secret,
            "server": server,
            "title": title
        ]
        if let urlQ { dict["url_q"] = urlQ }
        if let urlO { dict["url_o"] = urlO }
        if let oWidth { dict["o_width"] = oWidth }
        if let oHeight { dict["o_height"] = oHeight }
        if let widthQ { dict["width_q"] = widthQ }
        if let heightQ { dict["height_q"] = heightQ }
        return dict
    }
}
