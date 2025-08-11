//
//  SearchElement.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10.
//

import Foundation

struct SearchElementModel: Hashable, Codable, Identifiable {
    let id: String
    let title: String
    let dateCreated: Date
    
    init(
        id: String = UUID().uuidString,
        title: String,
        dateCreated: Date = .now
    ) {
        self.id = id
        self.title = title
        self.dateCreated = dateCreated
    }
    
    static var mock: Self {
        SearchElementModel(title: "Example Search", dateCreated: .now)
    }
    
    static var mocks: [Self] {
        [
            SearchElementModel(title: "Alpha Search", dateCreated: .now),
            SearchElementModel(title: "Beta Search", dateCreated: .now.addingTimeInterval(-86400)),
            SearchElementModel(title: "Gamma Search", dateCreated: .now.addingTimeInterval(-172800))
        ]
    }
}
