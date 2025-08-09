//
//  ImageListInteractor.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Foundation

@MainActor
protocol ImageListInteractor {
    func loadMoreImages(
        query: String,
        isPaginating: Bool,
        forceRefresh: Bool
    ) async throws -> [ImageAsset]

    func getInitialMessages(
            query: String,
            isPaginating: Bool,
            forceRefresh: Bool
        ) async throws -> [ImageAsset]
}

extension ImageListInteractor {
    func loadMoreImages(
        query: String,
        isPaginating: Bool = true,
        forceRefresh: Bool = false
    ) async throws -> [ImageAsset] {
        try await loadMoreImages(query: query, isPaginating: isPaginating, forceRefresh: forceRefresh)
    }

    func getInitialMessages(
            query: String,
            isPaginating: Bool = false,
            forceRefresh: Bool = false
    ) async throws -> [ImageAsset] {
        try await getInitialMessages(query: query, isPaginating: isPaginating, forceRefresh: forceRefresh)

    }
}

extension CoreInteractor: ImageListInteractor { }
