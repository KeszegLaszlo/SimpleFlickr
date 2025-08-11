//
//  ImagePreviewPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Observation
import SwiftUI
import Logger
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

    /// Call from the view's `.onAppear` or `.task` to track screen impressions.
    func onAppear() {
        interactor.trackScreenEvent(event: Event.viewAppeared)
    }


    /// Handles the action when the close button is tapped.
    /// Calls the router to dismiss the current screen.
    func closeButtonDidTap() {
        interactor.trackEvent(event: Event.closeButtonDidTap)
        router.dismissScreen()
    }


    /// Analytics and diagnostic events emitted by `MediaPreviewPresenter`.
    private enum Event: LoggableEvent {
        case viewAppeared
        case closeButtonDidTap

        var eventName: String {
            switch self {
            case .viewAppeared: "MediaPreviewView"
            case .closeButtonDidTap: "MediaPreviewPresenter_CloseButton_DidTap"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .viewAppeared:
                return nil
            case .closeButtonDidTap:
                return nil
            }
        }

        var type: LogType {
            switch self {
            default: .analytic
            }
        }
    }
}
