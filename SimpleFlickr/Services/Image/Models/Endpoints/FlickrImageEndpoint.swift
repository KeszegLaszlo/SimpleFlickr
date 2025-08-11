//
//  FlickrImageEndpoint.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation
import CustomNetworking

enum FlickrImageEndpoint: EndpointProvider {
    case search(query: String, page: Int, perPage: Int)

    //TODO: Handle api injection sendable
    nonisolated(unsafe) static var injectedAPIKey: String?

    var scheme: String { "https" }
    var baseURL: String { "api.flickr.com" }
    var port: Int? { nil }
    var apiKey: String? { Self.injectedAPIKey }
    var apiKeyHeaderField: String? { nil }
    var apiKeyQueryName: String? { "api_key" }
    var body: [String: Any]? { nil }
    var mockFile: String? { nil }
    
    var path: String {
        switch self {
        case .search: "/services/rest"
        }
    }

    var method: RequestMethod {
        switch self {
        case .search: .get
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .search(query, page, perPage):
            [
                .init(name: "method", value: "flickr.photos.search"),
                .init(name: "text", value: query),
                .init(name: "page", value: String(page)),
                .init(name: "per_page", value: String(perPage)),
                .init(name: "format", value: "json"),
                .init(name: "nojsoncallback", value: "1"),
                .init(name: "extras", value: "url_q,url_o,o_dims")
            ]
        }
    }
}
