//
//  ImageDetailsView.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import Router
import UserInterface

struct DetailsViewDelegate {
    var image: ImageAsset
}

struct ImageDetailsView: View {
    let delegate: DetailsViewDelegate

    @State var presenter: ImageDetailsPresenter

    var body: some View {
        ViewThatFits(content: {
            VStack(spacing: 10) {
                imageSection
                detailsSection
            }

            ScrollView {
                VStack(spacing: 10) {
                    imageSection
                    detailsSection
                }
            }
        })
        .padding(10)
        .navigationTitle(delegate.image.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var imageSection: some View {
        let imageUrl = delegate.image.original ?? delegate.image.thumbnail
        ImageLoaderView(url: imageUrl)
            .frame(height: 320)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.08), radius: 16, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.10), lineWidth: 1.5)
            )
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.indigo.opacity(0.22), .blue.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .blur(radius: 24)
                    .opacity(0.8)
                    .offset(y: 24)
                    .frame(height: 340) // Slightly larger to peek around the image
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, -12)
            .padding(.top, 2)
            .anyButton {
                presenter.heroImageDidTap(url: imageUrl)
            }

    }

    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            labeledRow(systemName: "number", label: "ID", value: delegate.image.id)
            labeledRow(systemName: "textformat", label: "Title", value: delegate.image.title)
            labeledRow(systemName: "link", label: "Thumbnail", value: delegate.image.thumbnail.absoluteString)
            labeledRow(systemName: "photo", label: "Original", value: delegate.image.original?.absoluteString ?? "—")
            labeledRow(systemName: "person.crop.square", label: "Source", value: sourceText)
            HStack(spacing: 12) {
                Image(systemName: "aspectratio").foregroundStyle(.secondary)
                Text("Size: \(sizeText)").font(.callout)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 4)
    }

    // Helper for uniform labeled rows
    @ViewBuilder
    private func labeledRow(
        systemName: String,
        label: String,
        value: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .foregroundStyle(.secondary)
            Text("\(label): ")
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Text(value)
                .font(.callout)
                .lineLimit(2)
                .truncationMode(.middle)
                .foregroundStyle(.secondary)
        }
    }

    private var sizeText: String {
        guard let size = delegate.image.size else { return "unknown" }
        let width = size.width.map { String($0) } ?? "?"
        let height = size.height.map { String($0) } ?? "?"
        return "\(width)x\(height) px"
    }

    private var sourceText: String {
        switch delegate.image.source {
        case .flickr: return "Flickr"
        case .mock: return "Mock"
        case .other(let desc): return desc
        }
    }
}

#Preview("Image detail") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))

    RouterView { router in
        builder.imageDetails(router: router, delegate: .init(image: .mock))
    }
    .previewEnvironment()
}
