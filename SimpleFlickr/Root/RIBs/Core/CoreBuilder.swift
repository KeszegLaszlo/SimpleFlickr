//
//  CoreBuilder.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import UserInterface
import Router

@MainActor
struct CoreBuilder: Builder {
    let interactor: CoreInteractor

    func build() -> AnyView {
        RouterView { router in
            imageListView(router: router)
        }
        .any()
    }

    func imageListView(router: AnyRouter) -> some View {
        ImegeListView(
            presenter: ImageListPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
