//
//  CoreRouter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import Router

@MainActor
struct CoreRouter: GlobalRouter {
    let router: AnyRouter
    let builder: CoreBuilder

    func showImageDetails(delegate: DetailsViewDelegate) {
        router.showScreen(.push) { router in
            builder.imageDetails(router: router, delegate: delegate)
        }
    }

    func showImagePreview(delegate: MediaDelegate) {
        router.showScreen(.fullScreenCover) { router in
            builder.imagePreview(router: router, delegate: delegate)
        }
    }
}
