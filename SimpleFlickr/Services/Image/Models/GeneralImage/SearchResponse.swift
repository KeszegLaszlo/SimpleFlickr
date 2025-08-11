//
//  SearchResponse.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

struct SearchResponse<Item: Codable>: Codable {
    let items: [Item]
    let page: Page
}
