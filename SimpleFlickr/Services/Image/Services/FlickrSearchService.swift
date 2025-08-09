//
//  ImageAsset.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Foundation
import CustomNetworking

struct FlickrSearchService: ImageSearchService {
    private let apiKey: String
    let apiClient: any ApiProtocol

    init(
        apiKey: String,
        apiClient: any ApiProtocol
    ) {
        self.apiKey = apiKey
        self.apiClient = apiClient
    }

    func searchImages(
        query: String,
        page: Int,
        perPage: Int
    ) async throws -> SearchResponse<ImageAsset> {
        FlickrImageEndpoint.injectedAPIKey = apiKey
        do {
            let envelope: FlickrAPIEnvelope = try await apiClient.asyncRequest(
                endpoint: FlickrImageEndpoint.search(
                    query: query,
                    page: page,
                    perPage: perPage
                )
            )

            guard envelope.stat == "ok" else {
                let code = envelope.code ?? -1
                let message = envelope.message
                throw mapFlickrError(code: code, message: message)
            }
            guard let photos = envelope.photos else { throw ImageSearchError.invalidResponse }

            let assets: [ImageAsset] = photos.photo.compactMap { (photo) -> ImageAsset? in
                // Prefer URLs coming from `extras`, fall back to constructing
                // https://www.flickr.com/services/api/misc.urls.html
                let thumbURL: URL? = photo.thumbnailURL
                    ?? FlickrURLBuilder.url(server: photo.server, id: photo.id, secret: photo.secret, sizeSuffix: "q")
                let originalURL: URL? = photo.originalURL
                    ?? FlickrURLBuilder.url(server: photo.server, id: photo.id, secret: photo.secret, sizeSuffix: "b")

                guard let thumbURL = thumbURL else { return nil }

                return ImageAsset(
                    id: photo.id,
                    title: photo.title,
                    thumbnail: thumbURL,
                    original: originalURL,
                    size: ImageAsset.Size(
                        width: photo.originalWidth ?? photo.thumbnailWidth,
                        height: photo.originalHeight ?? photo.thumbnailHeight
                    ),
                    source: .flickr
                )
            }

            let pageMeta = Page(
                page: photos.page,
                perPage: photos.perpage,
                total: photos.totalInt,
                pages: photos.pages
            )

            return SearchResponse(items: assets, page: pageMeta)
        } catch let err as DecodingError {
            throw ImageSearchError.decoding(underlying: err)
        } catch {
            throw ImageSearchError.transport(underlying: error)
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func mapFlickrError(code: Int, message: String?) -> FlickrServiceError {
        switch code {
        case 1: .tooManyTags
        case 2, 5: .unknownUser
        case 3: .parameterlessSearchDisabled
        case 4: .noPermissionForPool
        case 10: .searchUnavailable
        case 11: .noValidMachineTags
        case 12: .exceededMachineTags
        case 17: .contactsOnly
        case 18: .illogicalArguments
        case 100: .invalidAPIKey
        case 105: .serviceUnavailable
        case 106: .writeFailed
        case 111: .formatNotFound
        case 112: .methodNotFound
        case 114: .invalidSOAPEnvelope
        case 115: .invalidXMLRPC
        case 116: .badURLFound
        default: .unknown(code: code, message: message)
        }
    }
}

// MARK: - Flickr DTOs (scoped internal)

private struct FlickrAPIEnvelope: Codable {
    let stat: String
    let code: Int?
    let message: String?
    let photos: FlickrPhotosDTO?
}

private struct FlickrPhotosDTO: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    // Flickr sometimes returns total as a string
    let total: String
    let photo: [FlickrPhotoDTO]

    var totalInt: Int { Int(total) ?? 0 }
}

private struct FlickrPhotoDTO: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let title: String
    // urls from `extras` (optional)
    let thumbnailURL: URL?
    let originalURL: URL?
    // dimensions (optional, present with o_dims)
    let originalWidth: Int?
    let originalHeight: Int?
    // These aren't always provided; keep optional
    let thumbnailWidth: Int?
    let thumbnailHeight: Int?

    private nonisolated enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, title
        case thumbnailURL = "url_q"
        case originalURL = "url_o"
        case originalWidth = "o_width"
        case originalHeight = "o_height"
        case thumbnailWidth = "width_q"
        case thumbnailHeight = "height_q"
    }
}

// MARK: - Flickr URL builder (fallback if `extras` missing)

private enum FlickrURLBuilder {
    static func url(server: String, id: String, secret: String, sizeSuffix: String) -> URL? {
        // https://live.staticflickr.com/{server-id}/{id}_{secret}_[size-suffix].jpg
        // size suffix examples: q=150 square, m=240, n=320, z=640, b=1024
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = "live.staticflickr.com"
        comps.path = "/\(server)/\(id)_\(secret)_\(sizeSuffix).jpg"
        return comps.url
    }
}

enum FlickrImageEndpoint: EndpointProvider {
    case search(query: String, page: Int, perPage: Int)

    static var injectedAPIKey: String?

    var scheme: String { "https" }
    var baseURL: String { "api.flickr.com" }
    var port: Int? { nil }
    var apiKey: String? { Self.injectedAPIKey }
    var apiKeyHeaderField: String? { nil }
    var apiKeyQueryName: String? { "api_key" }
    var body: [String: Any]? { nil }
    var mockFile: String? { nil }

    var path: String {
        "/services/rest"
    }

    var method: RequestMethod {
        .get
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
