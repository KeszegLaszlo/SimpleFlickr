//
//  ImageDetailsView.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI
import Router
import UserInterface

struct DetailsViewDelegate {
    var image: ImageAsset
}

struct ImageDetailsView: View {
    private enum Constants {
        static let hstackSpacing: CGFloat = 10
        static let vstackSpacing: CGFloat = 20
        static let detailsSpacing: CGFloat = 20
        static let imageSize: CGFloat = 22
        static let lineLimit = 2
        static let imageHeight: CGFloat = 320
        static let backgroundPeekHeight: CGFloat = 340
        static let cornerRadius: CGFloat = 24
        static let strokeOpacity: Double = 0.10
        static let strokeLineWidth: CGFloat = 1.5
        static let backgroundBlur: CGFloat = 24
        static let backgroundOpacity: Double = 0.8
        static let backgroundOffsetY: CGFloat = 24
        static let imageBackgroundOpcity: CGFloat = 0.12

        // swiftlint:disable:next nesting
        @MainActor enum Text {
            static let id: LocalizedStringKey = "detailsId"
            static let title: LocalizedStringKey = "detailsTitle"
            static let thumbnail: LocalizedStringKey = "detailsThumbnail"
            static let original: LocalizedStringKey = "detailsOriginal"
            static let source: LocalizedStringKey = "detailsSource"
            static let size: LocalizedStringKey = "detailsSize"
            static let imageOpenHint: LocalizedStringKey = "a11y.image_details.open_hint"
        }
    }

    let delegate: DetailsViewDelegate

    @State var presenter: ImageDetailsPresenter

    var body: some View {
        VStack(spacing: Constants.vstackSpacing) {
            imageSection
            detailsSection
            Spacer()
        }
        .padding(GlobalConstants.Size.bodyPadding)
        .withMeshGradientBackground
        .navigationTitle(delegate.image.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { presenter.onAppear() }
    }

    @ViewBuilder
    private var imageSection: some View {
        let imageUrl = delegate.image.original ?? delegate.image.thumbnail
        ImageLoaderView(url: imageUrl)
            .frame(height: Constants.imageHeight)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous))
            .shadow(
                color: GlobalConstants.Shadow.color,
                radius: GlobalConstants.Shadow.radius,
                y: GlobalConstants.Shadow.shadowY
            )
            .overlay(
                RoundedRectangle(cornerRadius: GlobalConstants.Size.cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(Constants.strokeOpacity), lineWidth: Constants.strokeLineWidth)
            )
            .background(
                RoundedRectangle(cornerRadius: GlobalConstants.Size.cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.indigo.opacity(Constants.imageBackgroundOpcity * 2), .blue.opacity(Constants.imageBackgroundOpcity)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: Constants.backgroundBlur)
                    .opacity(Constants.backgroundOpacity)
                    .offset(y: Constants.backgroundOffsetY)
                    .frame(height: Constants.backgroundPeekHeight) // Slightly larger to peek around the image
            )
            .clipShape(RoundedRectangle(cornerRadius: GlobalConstants.Size.cornerRadius, style: .continuous))
            .anyButton {
                presenter.heroImageDidTap(url: imageUrl)
            }
            .accessibilityLabel(Text(delegate.image.title))
            .accessibilityHint(Text(Constants.Text.imageOpenHint))
            .accessibilityAddTraits([.isImage, .isButton])
            .accessibilityValue(Text(sizeText))

    }

    @ViewBuilder
    private var detailsSection: some View {
        Grid(horizontalSpacing: Constants.hstackSpacing, verticalSpacing: Constants.detailsSpacing) {
            gridRow(systemName: "number", label: Constants.Text.id, value: delegate.image.id)
            gridRow(systemName: "textformat", label: Constants.Text.title, value: delegate.image.title)
            gridRow(systemName: "link", label: Constants.Text.thumbnail, value: delegate.image.thumbnail.absoluteString, isLink: true)
            gridRow(systemName: "photo", label: Constants.Text.original, value: delegate.image.original?.absoluteString ?? "—", isLink: delegate.image.original != nil)
            gridRow(systemName: "person.crop.square", label: Constants.Text.source, value: delegate.image.source.displayName)
            gridRow(systemName: "aspectratio", label: Constants.Text.size, value: sizeText)
        }
        .padding()
        .background(
            .regularMaterial,
            in: RoundedRectangle(
                cornerRadius: GlobalConstants.Size.cornerRadius,
                style: .continuous
            )
        )
        .shadow(radius: GlobalConstants.Shadow.radius)
        .textSelection(.enabled)
    }

    // MARK: - Uniform labeled row
    @ViewBuilder
    private func gridRow(
        systemName: String,
        label: LocalizedStringKey,
        value: String,
        isLink: Bool = false
    ) -> some View {
        GridRow {
            Image(systemName: systemName)
                .foregroundStyle(.secondary)
                .frame(width: Constants.imageSize, alignment: .leading)
                .accessibilityHidden(true)

            Group {
                Text(label) + Text(":")
            }
            .fontWeight(.semibold)
            .gridColumnAlignment(.trailing)

            Group {
                if isLink, let url = URL(string: value) {
                    Link(value, destination: url)
                        .foregroundStyle(.blue)
                } else {
                    Text(value)
                        .foregroundStyle(.secondary)
                }
            }
            .font(.callout)
            .gridColumnAlignment(.leading)
            .lineLimit(Constants.lineLimit)
            .truncationMode(.middle)
            .accessibilityAddTraits(isLink ? .isLink : .isStaticText)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
        .accessibilityValue(Text(value))
    }

    private var sizeText: String {
        guard let size = delegate.image.size else { return "?" }
        let width = size.width.map { String($0) } ?? "?"
        let height = size.height.map { String($0) } ?? "?"
        return "\(width)x\(height) px"
    }
}

#Preview("Image detail") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))

    RouterView { router in
        builder.imageDetails(router: router, delegate: .init(image: .mock))
    }
    .previewEnvironment()
}
