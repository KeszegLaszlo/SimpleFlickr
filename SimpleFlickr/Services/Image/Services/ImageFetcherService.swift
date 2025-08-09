//
//  RemoteUserService.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

protocol ImageSearchService {
    var apiClient: ApiProtocol { get }

    func searchImages(
        query: String,
        page: Int,
        perPage: Int
    ) async throws -> SearchResponse<ImageAsset>
}

