//
//  ImegeListView.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import Router

struct ImegeListView: View {
    enum ViewState {
        enum EmptyReason { case notFoundForString(searchText: String), noFetchedResults}
        case empty(EmptyReason), loading, loaded
    }

    @State var presenter: ImageListPresenter

    var body: some View {
        VStack(spacing: .zero) {
            Button {
                Task {
                    await presenter.loadInitialImages()
                }
            } label: {
                Text("TESZT")
                    .font(.largeTitle)
            }

            switch presenter.viewState {
            case let .empty(reason):
                noResultsView(reason)
            case .loading:
                ProgressView().tint(.accent)
            case .loaded:
                loadedView
            }
        }
        .animation(.bouncy, value: presenter.isLoadingMore)
        .task { await presenter.loadInitialImages() }
    }

    @ViewBuilder
    private func noResultsView(_ reason: ViewState.EmptyReason) -> some View {
        switch reason {
        case .noFetchedResults:
            ContentUnavailableView.search
        case let .notFoundForString(searchText):
            ContentUnavailableView.search(text: searchText)
        }
    }

    private var loadedView: some View {
        VStack(spacing: .zero) {
            if presenter.isLoadingMore {
                ProgressView()
                    .tint(.accent)
            }

            List(presenter.images) { image in
                Text(image.title)
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview("Images Found") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))

    return RouterView { router in
        builder.imageListView(router: router)
    }
    .previewEnvironment()
}
