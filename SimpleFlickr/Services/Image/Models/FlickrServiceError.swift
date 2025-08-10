//
//  FlickrServiceError.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Foundation

/// Represents possible error cases returned by the Flickr API.
/// - SeeAlso: [Flickr API - flickr.photos.search](https://www.flickr.com/services/api/flickr.photos.search.html)
enum FlickrServiceError: Error {
    case tooManyTags
    case unknownUser
    case parameterlessSearchDisabled
    case noPermissionForPool
    case userDeleted
    case searchUnavailable
    case noValidMachineTags
    case exceededMachineTags
    case contactsOnly
    case illogicalArguments
    case invalidAPIKey
    case serviceUnavailable
    case writeFailed
    case formatNotFound
    case methodNotFound
    case invalidSOAPEnvelope
    case invalidXMLRPC
    case badURLFound
    case unknown(code: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .tooManyTags: "Too many tags in ALL query (max 20)."
        case .unknownUser: "Unknown user."
        case .parameterlessSearchDisabled: "Parameterless searches disabled. Use getRecent instead."
        case .noPermissionForPool: "You don't have permission to view this pool."
        case .userDeleted: "User deleted or not found."
        case .searchUnavailable: "Flickr search API is currently unavailable."
        case .noValidMachineTags: "No valid machine tags."
        case .exceededMachineTags: "Exceeded maximum allowable machine tags."
        case .contactsOnly: "You can only search within your own contacts."
        case .illogicalArguments: "Illogical or contradictory arguments."
        case .invalidAPIKey: "Invalid or expired API key."
        case .serviceUnavailable: "Service currently unavailable."
        case .writeFailed: "Write operation failed due to a temporary issue."
        case .formatNotFound: "Requested response format not found."
        case .methodNotFound: "Requested method not found."
        case .invalidSOAPEnvelope: "Invalid SOAP envelope."
        case .invalidXMLRPC: "Invalid XML-RPC method call."
        case .badURLFound: "Bad URL found in arguments (blocked for abuse)."
        case let .unknown(code, message): message ?? "Flickr error (code: \(code))."
        }
    }
}
