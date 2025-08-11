//
//  CoreBuilder.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
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
        ImageListView(
            presenter: ImageListPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func imageDetails(
        router: AnyRouter,
        delegate: DetailsViewDelegate
    ) -> some View {
        ImageDetailsView(
            delegate: delegate,
            presenter: ImageDetailsPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }

    func imagePreview(
        router: AnyRouter,
        delegate: MediaDelegate
    ) -> some View {
        MediaPreviewView(
            delegate: delegate,
            presenter: MediaPreviewPresenter(
                interactor: interactor,
                router: CoreRouter(router: router, builder: self)
            )
        )
    }
}
