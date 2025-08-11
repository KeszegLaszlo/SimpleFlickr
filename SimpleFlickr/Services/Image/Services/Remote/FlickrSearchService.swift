//
//  ImageAsset.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Foundation
import CustomNetworking

/// A concrete image-search service backed by the Flickr REST API.
///
/// This service wraps the `flickr.photos.search` endpoint and maps Flickr
/// responses into the app's neutral `ImageAsset` model.
///
/// Use `searchImages(query:page:perPage:)` to perform paginated searches.
///
/// - Important: You must supply a valid Flickr API key. The key is injected
///   into `FlickrImageEndpoint` before each request.
/// - SeeAlso: https://www.flickr.com/services/api/flickr.photos.search.html
struct FlickrSearchService: ImageSearchService {
    private let apiKey: String
    let apiClient: any ApiProtocol

    /// Creates a Flickr-backed search service.
    ///
    /// - Parameters:
    ///   - apiKey: Flickr API key used to authorize requests.
    ///   - apiClient: Networking client implementation used to execute requests.
    /// - Note: The `apiClient` must return decoded values of the requested type.
    init(
        apiKey: String,
        apiClient: any ApiProtocol
    ) {
        self.apiKey = apiKey
        self.apiClient = apiClient
    }

    /// Performs a Flickr photo search and maps results to `ImageAsset`s.
    ///
    /// This method calls `flickr.photos.search` with the provided query and
    /// pagination parameters, validates the envelope, and normalizes payloads
    /// (including flexible numeric/string fields) before returning items.
    ///
    /// - Parameters:
    ///   - query: Free‑text search query.
    ///   - page: 1‑based page index requested from Flickr.
    ///   - perPage: Page size (max allowed depends on Flickr plan).
    /// - Returns: A `SearchResponse` containing the mapped `ImageAsset`s and paging metadata.
    /// - Throws: `ImageSearchError` if transport, decoding, or API errors occur.
    /// - SeeAlso: https://www.flickr.com/services/api/flickr.photos.search.html
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
            try validateEnvelope(envelope)
            guard let photos = envelope.photos else { throw ImageSearchError.invalidResponse }

            let assets = mapPhotosToAssets(photos.photo)
            let pageMeta = makePage(from: photos)
            return SearchResponse(items: assets, page: pageMeta)
        } catch let err as DecodingError {
            throw ImageSearchError.decoding(underlying: err)
        } catch {
            throw ImageSearchError.transport(underlying: error)
        }
    }

    /// Ensures the Flickr envelope has an "ok" status and a `photos` payload; otherwise maps to domain errors.
    /// - Parameter envelope: The deserialized top‑level Flickr response.
    /// - Throws: `ImageSearchError` or `FlickrServiceError` when invalid.
    private func validateEnvelope(_ envelope: FlickrAPIEnvelope) throws {
        guard envelope.isOk else {
            let code = envelope.code ?? -1
            let message = envelope.message
            throw mapFlickrError(code: code, message: message)
        }
        guard envelope.photos != nil else {
            throw ImageSearchError.invalidResponse
        }
    }

    /// Maps Flickr photo DTOs into lightweight `ImageAsset` values, discarding entries that lack a thumbnail URL.
    private func mapPhotosToAssets(_ photos: [FlickrPhotoDTO]) -> [ImageAsset] {
        photos.compactMap { makeImageAsset(from: $0) }
    }

    /// Builds an `ImageAsset` from a single Flickr photo, preferring URLs provided via `extras` and falling back to constructed URLs.
    private func makeImageAsset(from photo: FlickrPhotoDTO) -> ImageAsset? {
        let (thumbURL, originalURL) = buildURLs(for: photo)
        guard let thumbURL = thumbURL else { return nil }
        let size = makeSize(from: photo)

        return .init(
            id: photo.id,
            title: photo.title,
            thumbnail: thumbURL,
            original: originalURL,
            size: size,
            source: .flickr
        )
    }

    /// Derives the thumbnail and original URLs, preferring `extras` fields; falls back to constructing URLs with `FlickrURLBuilder`.
    private func buildURLs(for photo: FlickrPhotoDTO) -> (thumbnailURL: URL?, originalURL: URL?) {
        let thumbURL: URL? = photo.thumbnailURL
            ?? FlickrURLBuilder.url(server: photo.server, id: photo.id, secret: photo.secret, sizeSuffix: "q")
        let originalURL: URL? = photo.originalURL
            ?? FlickrURLBuilder.url(server: photo.server, id: photo.id, secret: photo.secret, sizeSuffix: "b")
        return (thumbURL, originalURL)
    }

    /// Resolves the best‑available image dimensions, preferring original size when present; otherwise uses thumbnail size.
    private func makeSize(from photo: FlickrPhotoDTO) -> ImageAsset.Size {
        .init(
            width: photo.originalWidth ?? photo.thumbnailWidth,
            height: photo.originalHeight ?? photo.thumbnailHeight
        )
    }

    /// Converts Flickr paging metadata into the app's neutral `Page` model.
    private func makePage(from photos: FlickrPhotosDTO) -> Page {
        .init(
            page: photos.page,
            perPage: photos.perpage,
            total: photos.totalInt,
            pages: photos.pages
        )
    }

    /// Maps Flickr API error codes to `FlickrServiceError` cases.
    ///
    /// The mapping follows Flickr's documented error table for `flickr.photos.search` and related methods.
    /// Unknown codes are wrapped in `.unknown(code:message:)` for diagnostics.
    /// - Parameters:
    ///   - code: Flickr error code.
    ///   - message: Optional Flickr error message.
    /// - Returns: A `FlickrServiceError` suitable for surfacing at the domain layer.
    /// - SeeAlso: https://www.flickr.com/services/api/flickr.photos.search.html
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

/// Top‑level Flickr API envelope for search responses.
///
/// When `stat == "ok"`, the `photos` payload is expected to be present; otherwise, `code` and `message` describe the failure.
private struct FlickrAPIEnvelope: Decodable {
    let stat: String
    let code: Int?
    let message: String?
    let photos: FlickrPhotosDTO?

    var isOk: Bool { stat == "ok" }
}

/// Flickr `photos` container returned by `flickr.photos.search`.
///
/// Handles the `total` field which may arrive as a number or a string.
/// - SeeAlso: https://www.flickr.com/services/api/flickr.photos.search.html
private struct FlickrPhotosDTO: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    // Flickr may return total as number or string – normalize to Int
    let totalRaw: Int
    let photo: [FlickrPhotoDTO]

    /// Normalized integer view of `total` irrespective of wire type.
    var totalInt: Int { totalRaw }

    private enum CodingKeys: String, CodingKey { case page, pages, perpage, total, photo }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decode(Int.self, forKey: .page)
        self.pages = try container.decode(Int.self, forKey: .pages)
        self.perpage = try container.decode(Int.self, forKey: .perpage)

        if let intTotal = try? container.decode(Int.self, forKey: .total) {
            self.totalRaw = intTotal
        } else if let stringTotal = try? container.decode(String.self, forKey: .total), let intValue = Int(stringTotal) {
            self.totalRaw = intValue
        } else {
            self.totalRaw = .zero
        }

        self.photo = try container.decode([FlickrPhotoDTO].self, forKey: .photo)
    }
}

/// Minimal Flickr photo representation used for mapping to `ImageAsset`.
///
/// Includes optional URLs and dimensions populated via `extras` parameters (e.g., `url_q`, `url_o`, `o_width`).
/// - SeeAlso: https://www.flickr.com/services/api/flickr.photos.search.html
private struct FlickrPhotoDTO: Decodable {
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

    private enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, title
        case thumbnailURL = "url_q"
        case originalURL = "url_o"
        case originalWidth = "o_width"
        case originalHeight = "o_height"
        case thumbnailWidth = "width_q"
        case thumbnailHeight = "height_q"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.owner = try container.decode(String.self, forKey: .owner)
        self.secret = try container.decode(String.self, forKey: .secret)
        self.server = try container.decode(String.self, forKey: .server)
        self.title = (try? container.decode(String.self, forKey: .title)) ?? ""
        self.thumbnailURL = try? container.decode(URL.self, forKey: .thumbnailURL)
        self.originalURL = try? container.decode(URL.self, forKey: .originalURL)
        self.originalWidth = Self.decodeFlexibleIntIfPresent(from: container, forKey: .originalWidth)
        self.originalHeight = Self.decodeFlexibleIntIfPresent(from: container, forKey: .originalHeight)
        self.thumbnailWidth = Self.decodeFlexibleIntIfPresent(from: container, forKey: .thumbnailWidth)
        self.thumbnailHeight = Self.decodeFlexibleIntIfPresent(from: container, forKey: .thumbnailHeight)
    }

    private static func decodeFlexibleIntIfPresent(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Int? {
        if let intValue = try? container.decode(Int.self, forKey: key) {
            return intValue
        }
        if let stringValue = try? container.decode(String.self, forKey: key),
           let intValue = Int(stringValue) {
            return intValue
        }
        return nil
    }
}

// MARK: - Flickr URL builder (fallback if `extras` missing)

/// Utilities for constructing Flickr static image URLs when `extras` are absent.
///
/// Follows the documented pattern: `https://live.staticflickr.com/{server-id}/{id}_{secret}_[size-suffix].jpg`.
/// - SeeAlso: https://www.flickr.com/services/api/flickr.photos.search.html
private enum FlickrURLBuilder {
    /// Builds a static image URL for a given size suffix (e.g., `q`, `m`, `n`, `z`, `b`).
    /// - Parameters:
    ///   - server: Flickr server ID.
    ///   - id: Photo ID.
    ///   - secret: Photo secret.
    ///   - sizeSuffix: Flickr size code (e.g., `q`=150 square, `b`≈1024 on long edge).
    /// - Returns: A valid `URL` if components form a proper URL.
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
