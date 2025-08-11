//
//  ImageAssetTests.swift
//  SimpleFlickrTests
//
//  Created by Keszeg László on 2025.08.11.
//

import Foundation
import Testing
import Utilities
@testable import SimpleFlickr_Dev

@MainActor
struct ImageAssetTests {

    @Test("ImageAsset Initialization with Full Data")
    func testInitializationWithFullData() {
        let id = String.random
        let title = "Title - \(String.random)"
        let thumb = url("https://example.com/thumb.jpg")
        let original = url("https://example.com/original.jpg")
        let size: ImageAsset.Size = .init(width: 1024, height: 768)
        let source: ImageAsset.Source = .flickr

        let asset = ImageAsset(
            id: id,
            title: title,
            thumbnail: thumb,
            original: original,
            size: size,
            source: .flickr
        )

        #expect(asset.id == id)
        #expect(asset.title == title)
        #expect(asset.thumbnail == thumb)
        #expect(asset.original == original)
        #expect(asset.size == size)
        #expect(asset.source == source)
    }

    @Test("ImageAsset Initialization with Minimal Data")
    func testInitializationWithMinimalData() {
        let id = String.random
        let title = String.random
        let thumb = url("https://example.com/t.jpg")

        let asset = ImageAsset(
            id: id,
            title: title,
            thumbnail: thumb,
            source: .mock
        )

        #expect(asset.id == id)
        #expect(asset.title == title)
        #expect(asset.thumbnail == thumb)
        #expect(asset.original == nil)
        #expect(asset.size == nil)
        #expect(asset.source == .mock)
    }

    @Test("ImageAsset.Source displayName")
    func testSourceDisplayName() {
        #expect(ImageAsset.Source.flickr.displayName == "Flickr")
        #expect(ImageAsset.Source.mock.displayName == "Mock")
        let provider = String.random
        #expect(ImageAsset.Source.other(provider).displayName == provider)
    }

    @Test("ImageAsset Mock Data")
    func testMockData() throws {
        let mock = ImageAsset.mock
        #expect(mock.id == "mock-asset-1")
        #expect(mock.title == "Mock Image")
        #expect(mock.thumbnail == Utilities.sampleImageURL)
        #expect(mock.original == Utilities.sampleImageURL)
        #expect(mock.size == ImageAsset.Size(width: 800, height: 600))
        #expect(mock.source == .mock)
    }

    @Test("ImageAsset Hashable & Equatable semantics")
    func testHashableEquatable() {
        let base = ImageAsset(
            id: "same-id",
            title: "A",
            thumbnail: url("https://example.com/a.jpg"),
            original: nil,
            size: .init(width: 1, height: 1),
            source: .mock
        )

        let identical = ImageAsset(
            id: "same-id",
            title: "A",
            thumbnail: url("https://example.com/a.jpg"),
            original: nil,
            size: .init(width: 1, height: 1),
            source: .mock
        )

        let sameIDDifferentProps = ImageAsset(
            id: "same-id",
            title: "B",
            thumbnail: url("https://example.com/b.jpg"),
            original: url("https://example.com/b-orig.jpg"),
            size: .init(width: 2, height: 2),
            source: .flickr
        )

        var set: Set<ImageAsset> = []
        set.insert(base)
        set.insert(identical) // should not increase count
        set.insert(sameIDDifferentProps) // different props -> different element because Equatable is synthesized on all properties

        #expect(base == identical)
        #expect(base != sameIDDifferentProps)
        #expect(set.count == 2)
    }

    @Test("ImageAsset Codable Roundtrip - Flickr")
    func testCodableRoundtripFlickr() throws {
        let asset = ImageAsset(
            id: String.random,
            title: String.random,
            thumbnail: url("https://example.com/t.jpg"),
            original: url("https://example.com/o.jpg"),
            size: .init(width: 640, height: 480),
            source: .flickr
        )

        let data = try JSONEncoder().encode(asset)
        let decoded = try JSONDecoder().decode(ImageAsset.self, from: data)

        #expect(decoded == asset)
    }

    @Test("ImageAsset Codable Roundtrip - Other Provider")
    func testCodableRoundtripOther() throws {
        let provider = "Unsplash"
        let asset = ImageAsset(
            id: String.random,
            title: String.random,
            thumbnail: url("https://example.com/t2.jpg"),
            source: .other(provider)
        )

        let data = try JSONEncoder().encode(asset)
        let decoded = try JSONDecoder().decode(ImageAsset.self, from: data)

        #expect(decoded == asset)
    }

    // MARK: - Helpers
    private func url(_ urlString: String) -> URL { URL(string: urlString)! }
}
