//
//  AnyAppAlert.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

@MainActor
struct AnyAppAlert: Sendable {
    var title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    var buttons: @Sendable () -> AnyView

    init(
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        buttons: (@Sendable () -> AnyView)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = buttons ?? {
            AnyView(
                Button("OK", action: {

                })
            )
        }
    }

    init(error: any Error) {
        self.init(title: "Error", subtitle: LocalizedStringKey(error.localizedDescription), buttons: nil)
    }
}
