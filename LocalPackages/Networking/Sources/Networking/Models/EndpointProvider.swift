//
//  EndpointProvider.swift
//  Networking
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Foundation

public enum EndpointError: Error {
    case invalidURL
    case bodyEncodingFailed
}

/// Protocol defining the requirements for constructing network endpoints.
public protocol EndpointProvider {
    /// The URL scheme (e.g., "https").
    var scheme: String { get }
    /// The base URL or host (e.g., "api.example.com").
    var baseURL: String { get }
    /// The path component of the URL (e.g., "/v1/users").
    var path: String { get }
    /// The HTTP method to use for the request.
    var method: RequestMethod { get }
    /// Optional query parameters to include in the URL.
    var queryItems: [URLQueryItem]? { get }
    /// Optional HTTP body content as a dictionary.
    var body: [String: Any]? { get }
    /// Optional filename for mock responses.
    var mockFile: String? { get }
    /// Optional port number for the URL.
    var port: Int? { get }
    /// Optional API key value.
    var apiKey: String? { get }
    /// Optional header field name for the API key.
    var apiKeyHeaderField: String? { get }
    /// Optional query parameter name for the API key.
    var apiKeyQueryName: String? { get }
    /// The current language code for localization purposes.
    var currentLanguageCode: String { get }
}

public extension EndpointProvider {
    /// Default: no header-based key
    var apiKeyHeaderField: String? { nil }
    /// Default: no query-based key
    var apiKeyQueryName: String? { nil }
    /// Default language from current locale
    var currentLanguageCode: String { Locale.current.language.languageCode?.identifier ?? "en" }
}

public extension EndpointProvider {
    @MainActor
    func asURLRequest() throws -> URLRequest {

        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = baseURL
        if let port {
            urlComponents.port = port
        }
        urlComponents.path = path

        var items = queryItems ?? []
        if let apiKeyQueryName, let apiKey {
            items.append(URLQueryItem(name: apiKeyQueryName, value: "\(apiKey)"))
        }
        if !items.isEmpty {
            urlComponents.queryItems = items
        }

        guard let url = urlComponents.url else {
            throw EndpointError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.addValue(currentLanguageCode, forHTTPHeaderField: "Language")

        if let apiKeyHeaderField,
          let apiKey {
            urlRequest.addValue("\(apiKey)", forHTTPHeaderField: apiKeyHeaderField)
        }

        if let body = body {
            do {
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            } catch {
                throw EndpointError.bodyEncodingFailed
            }
        }
        return urlRequest
    }
}
