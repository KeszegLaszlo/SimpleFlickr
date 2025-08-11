//
//  ImageSearchError.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

enum ImageSearchError: Error, Sendable {
    case badRequest
    case transport(underlying: Error)
    case decoding(underlying: Error)
    case invalidResponse
    case noURLForItem
}
