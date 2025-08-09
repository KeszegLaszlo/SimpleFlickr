//
//  ApiProtocol.swift
//  Networking
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Foundation

@MainActor
protocol ApiProtocol {
    func asyncRequest<T: Decodable>(endpoint: any EndpointProvider) async throws -> T
}
