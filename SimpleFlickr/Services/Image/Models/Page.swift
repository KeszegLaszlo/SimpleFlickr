//
//  Page.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

 struct Page: Equatable, Codable, Sendable {
    let page: Int
    let perPage: Int
    let total: Int
    let pages: Int

    var hasNext: Bool { page < pages }
}
