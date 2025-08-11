//
//  MockApiService.swift
//  Networking
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation

public class MockApiService: Mockable, ApiProtocol {
    public init() {}

    public func asyncRequest<T>(endpoint: any EndpointProvider) async throws -> T where T: Decodable {
        guard let mockFile = endpoint.mockFile else {
            throw ApiServiceError.endpoint(.invalidURL)
        }
        return loadJSON(filename: mockFile, type: T.self)
    }
}
