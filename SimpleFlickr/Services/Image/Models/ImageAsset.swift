//
//  ImageAsset 2.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Foundation

struct ImageAsset: Hashable, Codable, Identifiable {
    struct Size: Hashable, Codable {
        public let width: Int?
        public let height: Int?
        public init(width: Int? = nil, height: Int? = nil) {
            self.width = width
            self.height = height
        }
    }

    enum Source: Hashable, Codable {
        case flickr
        case mock
        case other(String)
    }

    let id: String
    let title: String
    let thumbnail: URL
    let original: URL?
    let size: Size?
    let source: Source

    init(
        id: String,
        title: String,
        thumbnail: URL,
        original: URL? = nil,
        size: Size? = nil,
        source: Source
    ) {
        self.id = id
        self.title = title
        self.thumbnail = thumbnail
        self.original = original
        self.size = size
        self.source = source
    }
}
