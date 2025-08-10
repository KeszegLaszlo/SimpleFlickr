//
//  ImagePreviewPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Observation
import SwiftUI

/// The presenter responsible for handling the presentation logic of `MediaPreviewView`.
/// Coordinates between the interactor for business logic and the router for navigation.
@Observable
@MainActor
class MediaPreviewPresenter {
    private let interactor: any MediaPreviewInteractor
    private let router: any MediaPreviewRouter

    /// Creates a new `MediaPreviewPresenter`.
    /// - Parameters:
    ///   - interactor: The interactor that handles the business logic for the media preview.
    ///   - router: The router responsible for navigation and dismissal.
    init(interactor: any MediaPreviewInteractor, router: any MediaPreviewRouter) {
        self.interactor = interactor
        self.router = router
    }

    /// Handles the action when the close button is tapped.
    /// Calls the router to dismiss the current screen.
    func closeButtonDidTap() {
        router.dismissScreen()
    }
}
