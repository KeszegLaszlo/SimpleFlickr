//
//  ImageDetailsPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Observation
import SwiftUI

@Observable
@MainActor
class ImageDetailsPresenter {
    private let interactor: any ImageDetailsInteractor
    private let router: any ImageDetailsRouter

    init(interactor: any ImageDetailsInteractor, router: any ImageDetailsRouter) {
        self.interactor = interactor
        self.router = router
    }

    func heroImageDidTap(url: URL) {
        router.showImagePreview(delegate: .init(mediaContent: .singleImage(url)))
    }
}
