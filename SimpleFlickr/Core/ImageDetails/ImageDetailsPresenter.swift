//
//  ImageDetailsPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Observation
import SwiftUI
import Logger

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

    /// Call from the view's `.onAppear` or `.task` to track screen impressions.
    func onAppear() {
        interactor.trackScreenEvent(event: Event.viewAppeared)
    }

    /// Handles the event when the main image is tapped.
    /// - Parameter url: The URL of the tapped image.
    /// Triggers the router to present the image in a preview view.
    func heroImageDidTap(url: URL) {
        interactor.trackEvent(event: Event.heroImageDidTap(urlString: url.absoluteString))
        router.showImagePreview(delegate: .init(mediaContent: .singleImage(url)))
    }

    /// Analytics and diagnostic events emitted by `ImageDetailsPresenter`.
    private enum Event: LoggableEvent {
        case viewAppeared
        case heroImageDidTap(urlString: String)

        var eventName: String {
            switch self {
            case .viewAppeared: "ImageDetailsView"
            case .heroImageDidTap: "ImageDetailsPresenter_HeroImage_DidTap"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .viewAppeared:
                return nil
            case .heroImageDidTap(let urlString):
                return ["url": urlString]
            }
        }

        var type: LogType {
            switch self {
            default: .analytic
            }
        }
    }
}
