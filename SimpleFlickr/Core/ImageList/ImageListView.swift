//
//  ImegeListView.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import Router
import UserInterface

struct ImageListView: View {
    private enum Constants {
        enum Text {
            static let placeholder: LocalizedStringKey = "Search images..."
        }

        static let textfieldImageName: String = "magnifyingglass"
    }

    enum ViewState {
        enum EmptyReason { case notFoundForString(searchText: String), noFetchedResults}
        case empty(EmptyReason), loading, loaded
    }

    @State var presenter: ImageListPresenter

    var body: some View {
        VStack(spacing: .zero) {
            switch presenter.viewState {
            case let .empty(reason):
                noResultsView(reason)
            case .loading:
                ProgressView().tint(.accent)
            case .loaded:
                loadedView
            }
        }
        .withMeshGradientBackground
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
        ScrollView(.vertical) {
            LazyVStack(spacing: 6) {
                CompositionalLayout(count: presenter.layyoutId) {
                    ForEach(presenter.images) { image in
                        ImageLoaderView(url: image.thumbnail)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 0, y: 6)
                            .withCustomScrollTransition
                            .onAppear {
                                presenter.loadMoreData(image: image)
                            }
                            .anyButton(.press) {
                                presenter.onSelectImage(image)
                            }
                    }
                }
                .animation(.bouncy, value: presenter.layyoutId)
                if presenter.isLoadingMore {
                    ProgressView()
                        .tint(.accent)
                }
            }
            .padding(15)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .top, spacing: .zero) {
            searchField
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollTargetLayout()
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private var searchField: some View {
        CustomTextField(
            searchText: $presenter.searchText,
            placeholder: Constants.Text.placeholder,
            systemImageName: Constants.textfieldImageName
        )
    }
}

#Preview("Images Found") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))

    return RouterView { router in
        builder.imageListView(router: router)
    }
    .previewEnvironment()
}
