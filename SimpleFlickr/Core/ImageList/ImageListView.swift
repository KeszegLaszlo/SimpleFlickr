//
//  ImegeListView.swift
//  SimpleFlickr
//
//  Created yPosition Keszeg László on 2025. 08. 09.
//

import SwiftUI
import Router
import UserInterface

struct ImageListView: View {
    private enum Constants {
        // swiftlint:disable:next nesting
        @MainActor enum Text {
            static let placeholder: LocalizedStringKey = "placeholder"
            static let a11ySearchLabel: LocalizedStringKey = "a11y.search.label"
            static let a11ySearchHint: LocalizedStringKey = "a11y.search.hint"
            static let a11yNoImagesYet: LocalizedStringKey = "a11y.no_images_yet"
            static func a11yNoResults(for query: String) -> LocalizedStringKey { "a11y.no_results_for \(query)" }
            static let a11yOpenImageDetailsHint: LocalizedStringKey = "a11y.open_image_details.hint"
            static let a11yChipHint: LocalizedStringKey = "a11y.search_chip.hint"
            static func a11yChipLabel(_ title: String) -> LocalizedStringKey { "a11y.search_chip.label \(title)" }
        }
        // swiftlint:disable:next nesting
        enum Size {
            static let scrollItemSpacing: CGFloat = 6
            static let horizontalChipPadding: CGFloat = 18
            static let verticalChipPadding: CGFloat = 8
            static let chipSpacing: CGFloat = 10
            static let searchHistoryHorizontalPadding: CGFloat = 16
            static let searchHistoryVerticalPadding: CGFloat = 4
            static let panelSize: CGFloat = 180
            static let panelPadding: CGFloat = 16

            // swiftlint:disable:next nesting
            enum CanvasButton {
                static let anchorPadding: CGFloat = 44
                static let radialSpacing: CGFloat = 100
                static let diagonalSpacing: CGFloat = 100
                static let outerRing: CGFloat = 208
                static let innerRingSmall: CGFloat = 60
                static let innerRingMedium: CGFloat = 80
                static let hitCircleDiameter: CGFloat = 76
                static let panelYOffset: CGFloat = -29
            }
        }

        static let textfieldImageName: String = "magnifyingglass"

        // swiftlint:disable:next nesting
        enum ImagesScrollView {
            static let reducedScale: CGFloat = 0.8
            static let rotationDegreesWhenShown: Double = 20
            static let basePitch: CGFloat = 1
            static let shadowRadius: CGFloat = 50
            static let shadowYOffset: CGFloat = 50
            static let gradientLeadingOpacity: Double = 0.6
            static let gradientTrailingOpacity: Double = 0.3
            static let gradientStartPoint: UnitPoint = .topLeading
            static let gradientEndPoint: UnitPoint = .bottomTrailing
            static let blendMode: BlendMode = .overlay
        }
    }

    enum ViewState: Equatable {
        // swiftlint:disable:next nesting
        enum EmptyReason: Equatable { case notFoundForString(searchText: String), noFetchedResults}
        case empty(EmptyReason), loading, loaded
    }

    @State var presenter: ImageListPresenter
    @FocusState var isTextFieldIsFocused: Bool
    @State private var shouldAnimateFocus: Bool = false
    @State var dragOffset: CGSize = .zero

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
                imagesScrollView
                .overlay(alignment: .bottomTrailing) {
                    buttons
                }
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

    private var imagesScrollView: some View {
        ZStack {
            loadedView
                .scaleEffect(presenter.showLayoutSelector ? Constants.ImagesScrollView.reducedScale : 1)
                .rotation3DEffect(
                    .degrees(presenter.showLayoutSelector ? Constants.ImagesScrollView.rotationDegreesWhenShown : .zero),
                    axis: (x: Constants.ImagesScrollView.basePitch - presenter.pitch, y: presenter.roll, z: .zero)
                )
                .shadow(
                    color: GlobalConstants.Shadow.color,
                    radius: Constants.ImagesScrollView.shadowRadius,
                    x: .zero,
                    y: Constants.ImagesScrollView.shadowYOffset
                )

            LinearGradient(
                colors: [
                    .secondary.opacity(Constants.ImagesScrollView.gradientLeadingOpacity),
                    .secondary.opacity(Constants.ImagesScrollView.gradientTrailingOpacity)
                ],
                startPoint: Constants.ImagesScrollView.gradientStartPoint,
                endPoint: Constants.ImagesScrollView.gradientEndPoint
            )
            .opacity(presenter.showLayoutSelector ? 1 : .zero)
            .onTapGesture {
                presenter.toggleLayoutSelector()
            }
            .blendMode(Constants.ImagesScrollView.blendMode)
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
        .animation(nil, value: presenter.showLayoutSelector)
        .animation(nil, value: presenter.images)
        .animation(nil, value: shouldAnimateFocus)
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
            ScrollView(.horizontal) {
                HStack(spacing: Constants.Size.chipSpacing) {
                    ForEach(presenter.searchResults) { search in
                        chipView(for: search)
                    }
                }
                .padding(.horizontal, Constants.Size.searchHistoryHorizontalPadding)
                .padding(.vertical, Constants.Size.searchHistoryVerticalPadding)
            }
            .scrollIndicators(.hidden)
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

// Should move this canvas view to UserInterface package
private extension ImageListView {
    var buttons: some View {
        ZStack {
            Rectangle()
                .fill(presenter.showLayoutSelector ? .ultraThinMaterial : .ultraThickMaterial)
                .overlay(Rectangle().fill(.black.opacity(0.5)).blendMode(.softLight))
                .mask(
                    canvas.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                )
                .shadow(color: .white.opacity(0.2), radius: 0, x: -1, y: -1)
                .shadow(color: .black.opacity(0.2), radius: 0, x: 1, y: 1)
                .shadow(color: .black.opacity(0.5), radius: 10, x: 10, y: 10)
                .overlay(
                    GeometryReader { geo in
                        let xPosition = geo.size.width - Constants.Size.CanvasButton.anchorPadding
                        let yPosition = geo.size.height - Constants.Size.CanvasButton.anchorPadding
                        ZStack {
                            // main toggle icon on the center circle
                            Image(systemName: "squares.leading.rectangle")
                                .font(.system(size: 30))
                                .rotationEffect(.degrees(presenter.showLayoutSelector ? 45 : 0), anchor: .center)
                                .foregroundColor(.white)
                                .position(x: xPosition, y: yPosition)

                            Group {
                                Image(systemName: "rectangle")
                                    .foregroundColor(.white)
                                    .position(x: xPosition, y: yPosition - Constants.Size.CanvasButton.radialSpacing)
                                    .anyButton {
                                        presenter.updateLayoudId(to: 1)
                                    }

                                Image(systemName: "rectangle.split.2x1")
                                    .foregroundColor(.white)
                                    .position(x: xPosition - Constants.Size.CanvasButton.radialSpacing, y: yPosition)
                                    .anyButton {
                                        presenter.updateLayoudId(to: 2)

                                    }

                                Image(systemName: "rectangle.split.3x1")
                                    .foregroundColor(.white)
                                    .position(x: xPosition - Constants.Size.CanvasButton.diagonalSpacing, y: yPosition - Constants.Size.CanvasButton.diagonalSpacing)
                                    .anyButton {
                                        presenter.updateLayoudId(to: 3)
                                    }
                            }
                            .blur(radius: presenter.showLayoutSelector ? .zero : 10)
                            .opacity(presenter.showLayoutSelector ? 1 : .zero)
                            .scaleEffect(presenter.showLayoutSelector ? 1 : 0.5)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                )
                .background(
                    GeometryReader { geo in
                        let xPosition = geo.size.width - Constants.Size.CanvasButton.anchorPadding
                        let yPosition = geo.size.height - Constants.Size.CanvasButton.anchorPadding
                        ZStack {
                            // central visual ring
                            circle.frame(width: Constants.Size.CanvasButton.outerRing)
                                .position(x: xPosition, y: yPosition)
                            // inner rings
                            circle.frame(width: Constants.Size.CanvasButton.innerRingSmall)
                                .position(x: xPosition, y: yPosition)
                            circle.frame(width: Constants.Size.CanvasButton.innerRingMedium)
                                .position(x: xPosition, y: yPosition)
                        }
                        .scaleEffect(presenter.showLayoutSelector ? 1 : 0.8, anchor: .center)
                        .opacity(presenter.showLayoutSelector ? 1 : .zero)
                        .animation(.easeOut(duration: 0.3), value: presenter.showLayoutSelector)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    }
                )
                .offset(y: Constants.Size.CanvasButton.panelYOffset)
        }
        // Limit hit-test area so the overlay doesn't swallow ScrollView gestures
        .frame(width: Constants.Size.panelSize, height: Constants.Size.panelSize)
        .padding(Constants.Size.panelPadding)
        .onTapGesture {
            presenter.toggleLayoutSelector()
        }
        .gesture(drag)
    }

    var circle: some View {
        Circle().stroke(lineWidth: 1).fill(.linearGradient(colors: [Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)), Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0))], startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    var canvas: some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.8, color: .blue))
            context.addFilter(.blur(radius: 10))
            context.drawLayer { ctx in
                for index in 1...5 {
                    if let resolvedView = context.resolveSymbol(id: index) {
                        ctx.draw(resolvedView, at: CGPoint(x: size.width - Constants.Size.CanvasButton.anchorPadding, y: size.height - Constants.Size.CanvasButton.anchorPadding))
                    }
                }
            }
        } symbols: {
            Circle()
                .fill(.black)
                .frame(width: Constants.Size.CanvasButton.hitCircleDiameter, height: Constants.Size.CanvasButton.hitCircleDiameter)
                .tag(1)
            Circle()
                .fill(.black)
                .frame(width: Constants.Size.CanvasButton.hitCircleDiameter, height: Constants.Size.CanvasButton.hitCircleDiameter)
                .offset(dragOffset)
                .tag(2)
            Circle()
                .fill(.black)
                .frame(width: Constants.Size.CanvasButton.hitCircleDiameter, height: Constants.Size.CanvasButton.hitCircleDiameter)
                .offset(y: presenter.showLayoutSelector ? -Constants.Size.CanvasButton.radialSpacing : .zero)
                .tag(3)
            Circle()
                .fill(.black)
                .frame(width: Constants.Size.CanvasButton.hitCircleDiameter, height: Constants.Size.CanvasButton.hitCircleDiameter)
                .offset(x: presenter.showLayoutSelector ? -Constants.Size.CanvasButton.radialSpacing : .zero)
                .tag(4)
            Circle()
                .fill(.black)
                .frame(width: Constants.Size.CanvasButton.hitCircleDiameter, height: Constants.Size.CanvasButton.hitCircleDiameter)
                .offset(x: presenter.showLayoutSelector ? -Constants.Size.CanvasButton.diagonalSpacing : .zero, y: presenter.showLayoutSelector ? -Constants.Size.CanvasButton.diagonalSpacing : .zero)
                .tag(5)
        }
    }

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { _ in
                withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                    dragOffset = .zero
                }
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
