//
//  AvatarEntity.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 10..
//

import SwiftUI
import SwiftData

@Model
final class SearchElementEntity {
    @Attribute(.unique) var id: String
    var title: String
    var dateCreated: Date

    init(from model: SearchElementModel) {
        self.id = model.id
        self.title = model.title
        self.dateCreated = .now
    }
    
    @MainActor
    func toModel() -> SearchElementModel {
        .init(
            id: id,
            title: title,
            dateCreated: dateCreated
        )
    }
}
