//
//  ImagePreviewPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Observation
import SwiftUI

@Observable
@MainActor
class MediaPreviewPresenter {
    private let interactor: any MediaPreviewInteractor
    private let router: any MediaPreviewRouter

    init(interactor: any MediaPreviewInteractor, router: any MediaPreviewRouter) {
        self.interactor = interactor
        self.router = router
    }

    func closeButtonDidTap() {
        router.dismissScreen()
    }
}
