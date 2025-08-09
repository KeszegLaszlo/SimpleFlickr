//
//  ImagePreviewView.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import UserInterface
import Router
import Utilities

enum MediaPreviewContent {
    case singleImage(URL)
    case images([URL])
}

struct MediaDelegate {
    var mediaContent: MediaPreviewContent
}

struct MediaPreviewView: View {
    let delegate: MediaDelegate

    @State var presenter: MediaPreviewPresenter

    var body: some View {
        VStack {
            switch delegate.mediaContent {
            case let .singleImage(url):
                imageView(url: url)
            case let .images(urls):
                ImagesView(urls: urls)
            }
        }
        .background(.ultraThinMaterial)
        .overlay(alignment: .topTrailing) {
            FancyButton(style: .xmark, size: 30) {
                Task { @MainActor in
                    presenter.closeButtonDidTap()
                }
            }
        }
    }

    private func imageView(url: URL) -> some View {
        ImageLoaderView(url: url, resizingMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .centered()
            .ignoresSafeArea()
    }

    private struct ImagesView: View {
        let urls: [URL]
        @State var selectedIndex = 0
        var body: some View {
            VStack {
                // Main large image
                ImageLoaderView(url: urls[selectedIndex])
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 450)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(radius: 18)
                    .padding(.vertical, 10)
                    .animation(.easeInOut(duration: 0.25), value: selectedIndex)

                // Thumbnail strip
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(urls.indices, id: \.self) { idx in
                            ImageLoaderView(url: urls[idx])
                                .aspectRatio(contentMode: .fill)
                                .frame(width: selectedIndex == idx ? 74 : 54, height: selectedIndex == idx ? 74 : 54)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(selectedIndex == idx ? Color.accentColor : Color.clear, lineWidth: 3)
                                )
                                .shadow(radius: selectedIndex == idx ? 8 : 0)
                                .scaleEffect(selectedIndex == idx ? 1.15 : 1.0)
                                .animation(.easeInOut(duration: 0.22), value: selectedIndex == idx)
                                .onTapGesture {
                                    selectedIndex = idx
                                }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
        }
    }
}

private extension View {
    func centered() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                self
                Spacer()
            }
            Spacer()
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
