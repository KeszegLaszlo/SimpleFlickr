//
//  ApiService.swift
//  Networking
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Foundation

/// Represents possible errors returned by `ApiService` during networking operations.
///
/// - endpoint: An error occurred while constructing the URL request from an endpoint.
/// - invalidResponse: The response received was not a valid HTTP response.
/// - http: The server responded with an HTTP error status code and optional data.
/// - decoding: An error occurred while decoding the response data.
/// - transport: A transport-level error occurred (e.g., network connection failed).
public enum ApiServiceError: Error {
    case endpoint(EndpointError)
    case invalidResponse
    case http(statusCode: Int, data: Data)
    case decoding(any Error)
    case transport(any Error)
}

/// A generic network service for performing API requests and decoding responses.
///
/// `ApiService` provides methods to asynchronously fetch and decode data from endpoints conforming to `EndpointProvider`.
public final class ApiService: ApiProtocol {
    public enum Constants {
        public static let timeoutIntervalForRequest: TimeInterval = 60
        public static let timeoutIntervalForResource: TimeInterval = 300
        public static let acceptedStatusCodes = 200...299
    }
    private let decoder: JSONDecoder
    private let session: URLSession

    /// Initializes a new instance of `ApiService`.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` used for network requests. Defaults to a session with standard configuration and timeouts.
    ///   - decoder: The `JSONDecoder` used for decoding response data. Defaults to an ISO8601 date decoding strategy.
    public init(
        /// The `URLSession` used for network requests. Defaults to a session with waits for connectivity and custom timeouts.
        session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.waitsForConnectivity = true
            configuration.timeoutIntervalForRequest = Constants.timeoutIntervalForRequest
            configuration.timeoutIntervalForResource = Constants.timeoutIntervalForResource
            return URLSession(configuration: configuration)
        }(),
        /// The `JSONDecoder` used for decoding response data. Defaults to ISO8601 date decoding.
        decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return decoder
        }()
    ) {
        self.session = session
        self.decoder = decoder
    }

    // MARK: - Methods
    /// Performs an asynchronous network request and decodes the response into the specified type.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint describing the request to be performed.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `ApiServiceError` if the request fails, the response is invalid, or decoding fails.
    public func asyncRequest<T: Decodable>(endpoint: any EndpointProvider) async throws -> T {
        let request = try makeRequest(from: endpoint)
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw ApiServiceError.transport(error)
        }
        try validate(response, data: data)
        return try decode(T.self, from: data)
    }

    /// Performs an asynchronous network request and returns the raw response data.
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint describing the request to be performed.
    /// - Returns: The raw response data.
    /// - Throws: `ApiServiceError` if the request fails or the response is invalid.
    func asyncRequest(endpoint: any EndpointProvider) async throws -> Data {
        let request = try makeRequest(from: endpoint)
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw ApiServiceError.transport(error)
        }
        try validate(response, data: data)
        return data
    }

    // MARK: - Helpers
    /// Constructs a `URLRequest` from the provided endpoint, mapping endpoint errors to `ApiServiceError`.
    private func makeRequest(from endpoint: any EndpointProvider) throws -> URLRequest {
        do {
            return try endpoint.asURLRequest()
        } catch let endpointError as EndpointError {
            throw ApiServiceError.endpoint(endpointError)
        } catch {
            throw ApiServiceError.endpoint(.invalidURL)
        }
    }

    /// Validates that the response is an HTTP response with a successful status code.
    private func validate(_ response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw ApiServiceError.invalidResponse }
        guard (Constants.acceptedStatusCodes).contains(http.statusCode) else {
            throw ApiServiceError.http(statusCode: http.statusCode, data: data)
        }
    }

    /// Decodes the provided data into the specified `Decodable` type, mapping decoding errors to `ApiServiceError`.
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw ApiServiceError.decoding(error)
        }
    }
}

