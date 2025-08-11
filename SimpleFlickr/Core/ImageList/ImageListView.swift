//
//  ImegeListView.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI
import Router
import UserInterface

struct ImageListView: View {
    private enum Constants {
        @MainActor
        enum Text {
            static let placeholder: LocalizedStringKey = "placeholder"
            static let a11ySearchLabel: LocalizedStringKey = "a11y.search.label"
            static let a11ySearchHint: LocalizedStringKey = "a11y.search.hint"
            static let a11yNoImagesYet: LocalizedStringKey = "a11y.no_images_yet"
            static func a11yNoResults(for query: String) -> LocalizedStringKey { "a11y.no_results_for \(query)" }
            static let a11yOpenImageDetailsHint: LocalizedStringKey = "a11y.open_image_details.hint"
            static let a11yChipHint: LocalizedStringKey = "a11y.search_chip.hint"
            static func a11yChipLabel(_ title: String) -> LocalizedStringKey { "a11y.search_chip.label \(title)" }
        }

        enum Size {
            static let scrollItemSpacing: CGFloat = 6
            static let horizontalChipPadding: CGFloat = 18
            static let verticalChipPadding: CGFloat = 8
            static let chipSpacing: CGFloat = 10
            static let searchHistoryHorizontalPadding: CGFloat = 16
            static let searchHistoryVerticalPadding: CGFloat = 4
        }

        static let textfieldImageName: String = "magnifyingglass"
    }

    enum ViewState: Equatable {
        enum EmptyReason: Equatable { case notFoundForString(searchText: String), noFetchedResults}
        case empty(EmptyReason), loading, loaded
    }

    @State var presenter: ImageListPresenter
    @FocusState var isTextFieldIsFocused: Bool
    @State private var shouldAnimateFocus: Bool = false

    var body: some View {
        VStack(spacing: .zero) {
            switch presenter.viewState {
            case let .empty(reason):
                noResultsView(reason)
            case .loading:
                ProgressView()
                  .tint(.indigo)
                  .controlSize(.large)
            case .loaded:
                loadedView
            }
        }
        .blur(radius: isTextFieldIsFocused ? 10 : .zero)
        .animation(.bouncy, value: shouldAnimateFocus)
        .overlay(alignment: .top, content: {
            searchHistory
        })
        .safeAreaInset(edge: .top, spacing: .zero) {
            if presenter.viewState != .loading {
                searchField
            }
        }
        .withMeshGradientBackground
        .animation(.bouncy, value: presenter.isLoadingMore)
        .onChange(of: isTextFieldIsFocused) { _, focused in
            withAnimation(.bouncy) {
                shouldAnimateFocus = focused
            }
            Task { await presenter.onFocusChanged(focused) }
        }
        .onFirstTask { await presenter.loadImages() }
        .onFirstAppear {
            Task { @MainActor in
                presenter.onAppear()
            }
        }
    }

    @ViewBuilder
    private func noResultsView(_ reason: ViewState.EmptyReason) -> some View {
        switch reason {
        case .noFetchedResults:
            ContentUnavailableView.search
                .accessibilityLabel(Text(Constants.Text.a11yNoImagesYet))
        case let .notFoundForString(searchText):
            ContentUnavailableView.search(text: searchText)
                .accessibilityLabel(Text(Constants.Text.a11yNoResults(for: searchText)))
        }
    }

    private var loadedView: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: Constants.Size.scrollItemSpacing) {
                gridView
                    .allowsHitTesting(!isTextFieldIsFocused)
                if presenter.isLoadingMore {
                    ProgressView()
                        .tint(.accent)
                }
            }
            .animation(.bouncy, value: presenter.images)
            .padding(GlobalConstants.Size.bodyPadding)
        }
        .scrollDisabled(isTextFieldIsFocused)
        .animation(.bouncy, value: presenter.images)
        .refreshable {
            Task {
                await presenter.loadImages()
            }
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.immediately)
        .scrollTargetLayout()
        .contentShape(Rectangle())
        .onTapGesture {
            presenter.dismissKeyboard()
            isTextFieldIsFocused = false
        }
    }

    private var gridView: some View {
        CompositionalLayout(count: presenter.layyoutId) {
            ForEach(presenter.images) { image in
                ImageLoaderView(url: image.thumbnail)
                    .clipShape(RoundedRectangle(cornerRadius: GlobalConstants.Size.cornerRadius))
                    .shadow(
                        color: GlobalConstants.Shadow.color,
                        radius: GlobalConstants.Shadow.radius,
                        x: GlobalConstants.Shadow.shadowX,
                        y: GlobalConstants.Shadow.shadowY
                    )
                    .withCustomScrollTransition
                    .accessibilityHint(Text(Constants.Text.a11yOpenImageDetailsHint))
                    .onAppear {
                        presenter.loadMoreData(image: image)
                    }
                    .anyButton(.press) {
                        presenter.onSelectImage(image)
                    }
            }
        }
        .animation(.bouncy, value: presenter.layyoutId)
    }

    private var searchField: some View {
        CustomTextField(
            searchText: $presenter.searchText,
            isFocused: $isTextFieldIsFocused,
            placeholder: Constants.Text.placeholder,
            systemImageName: Constants.textfieldImageName
        ) {
            Task { await presenter.submitSearch() }
        }
        .accessibilityLabel(Text(Constants.Text.a11ySearchLabel))
        .accessibilityHint(Text(Constants.Text.a11ySearchHint))
        .accessibilityValue(Text(presenter.searchText))
    }

    @ViewBuilder
    private var searchHistory: some View {
        if shouldAnimateFocus {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Constants.Size.chipSpacing) {
                    ForEach(presenter.searchResults) { search in
                        chipView(for: search)
                    }
                }
                .padding(.horizontal, Constants.Size.searchHistoryHorizontalPadding)
                .padding(.vertical, Constants.Size.searchHistoryVerticalPadding)
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: .leading),
                    removal: .move(edge: .trailing)
                )
            )
        }
    }

    private func chipView(for search: SearchElementModel) -> some View {
        Text(search.title)
            .font(.callout.bold())
            .padding(.horizontal, Constants.Size.horizontalChipPadding)
            .padding(.vertical, Constants.Size.verticalChipPadding)
            .background(
                LinearGradient(
                    colors: [Color.accent.opacity(0.88), Color.accent.opacity(0.52)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .withCustomScrollTransition
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .anyButton(.press) {
                Task {
                    await presenter.historySearchDidTap(chip: search)
                }
            }
            .accessibilityLabel(Text(Constants.Text.a11yChipLabel(search.title)))
            .accessibilityHint(Text(Constants.Text.a11yChipHint))
    }
}

#Preview("Images Found") {
    let builder = CoreBuilder(interactor: CoreInteractor(container: DevPreview.shared.container()))

    return RouterView { router in
        builder.imageListView(router: router)
    }
    .previewEnvironment()
}
