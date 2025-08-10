//
//  ImageDetailsPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import Observation
import SwiftUI

/// The presenter responsible for managing the image details screen logic.
/// Handles user interactions and coordinates navigation via the router.
@Observable
@MainActor
class ImageDetailsPresenter {
    private let interactor: any ImageDetailsInteractor
    private let router: any ImageDetailsRouter

    /// Creates a new `ImageDetailsPresenter`.
    /// - Parameters:
    ///   - interactor: The interactor responsible for fetching and processing image details.
    ///   - router: The router responsible for navigation actions from the image details screen.
    init(interactor: any ImageDetailsInteractor, router: any ImageDetailsRouter) {
        self.interactor = interactor
        self.router = router
    }

    /// Handles the event when the main image is tapped.
    /// - Parameter url: The URL of the tapped image.
    /// Triggers the router to present the image in a preview view.
    func heroImageDidTap(url: URL) {
        router.showImagePreview(delegate: .init(mediaContent: .singleImage(url)))
    }
}
