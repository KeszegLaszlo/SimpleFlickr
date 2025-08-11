//
//  ImagePreviewView.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI
import UserInterface
import Router
import Utilities

/// Represents the different types of media that can be displayed in the `MediaPreviewView`.
/// - singleImage: A single image provided as a URL.
/// - images: Multiple images provided as an array of URLs.
enum MediaPreviewContent {
    case singleImage(URL)
    case images([URL])
    // Handle extra media type if needed
}

/// A delegate that holds the media content for the `MediaPreviewView`.
struct MediaDelegate {
    var mediaContent: MediaPreviewContent
}

/// A SwiftUI view responsible for previewing single or multiple media items.
/// Supports background styling and a close button.
struct MediaPreviewView: View {
    /// Constants used within `MediaPreviewView`.
    private enum Constants {
        static let mediaButtonSize: CGFloat = 30

        @MainActor
        enum Text {
            static let closeHint: LocalizedStringKey = "a11y.media_preview.close_hint"
            static func singleImageLabel(_ title: String) -> LocalizedStringKey { "a11y.media_preview.single_image_label \(title)" }
            static let multipleImagesLabel: LocalizedStringKey = "a11y.media_preview.multiple_images_label"
        }
    }

    let delegate: MediaDelegate

    @State var presenter: MediaPreviewPresenter

    /// The main body of the `MediaPreviewView`.
    /// Displays the media content with a gradient background and a close button overlay.
    var body: some View {
        content
            .onAppear { presenter.onAppear() }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(mediaAccessibilityLabel))
            .accessibilityHint(Text(Constants.Text.closeHint))
            .withMeshGradientBackground
            .overlay(alignment: .topTrailing) {
                FancyButton(style: .xmark, size: Constants.mediaButtonSize) {
                    Task { @MainActor in
                        presenter.closeButtonDidTap()
                    }
                }
                .padding()
                .accessibilityLabel(Text(Constants.Text.closeHint))
                .accessibilityAddTraits(.isButton)
            }
    }

    /// A view builder that renders the media content based on its type.
    @ViewBuilder
    private var content: some View {
        switch delegate.mediaContent {
        case let .singleImage(url):
            imageView(url: url)
        case .images:
            EmptyView()
            // Handle multiple image carrousel if needed
        }
    }

    /// Creates an image view for a given image URL.
    /// - Parameter url: The URL of the image to be displayed.
    /// - Returns: A SwiftUI view displaying the image.
    private func imageView(url: URL) -> some View {
        ImageLoaderView(url: url, resizingMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .ignoresSafeArea()
    }

    /// Accessibility label for the displayed media, based on its type.
    private var mediaAccessibilityLabel: LocalizedStringKey {
        switch delegate.mediaContent {
        case let .singleImage(url):
            Constants.Text.singleImageLabel(url.lastPathComponent)
        case .images:
            Constants.Text.multipleImagesLabel
        }
    }
}

#Preview {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))

    RouterView { router in
        builder.imagePreview(
            router: router,
            delegate: .init(mediaContent: .singleImage(Utilities.sampleImageURL))
        )
    }
    .previewEnvironment()
}
