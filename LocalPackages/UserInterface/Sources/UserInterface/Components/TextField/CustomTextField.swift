//
//  SwiftUIView.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

public struct CustomTextField: View {
    private enum Constants {
        enum Animation {
            static let response: CGFloat = 0.35
            static let dampingFraction: CGFloat = 0.6
            static let blendDuration: CGFloat = 0.5
        }
        enum Layout {
            static let verticalPadding: CGFloat = 12
            static let horizontalPadding: CGFloat = 15
            static let iconSpacing: CGFloat = 8
            static let cornerRadiusFocused: CGFloat = 0
            static let cornerRadiusUnfocused: CGFloat = 30
            static let topPaddingFocused: CGFloat = -100
            static let topPaddingUnfocused: CGFloat = 0
            static let horizontalPaddingFocused: CGFloat = 0
            static let horizontalPaddingUnfocused: CGFloat = 15
            static let bottomPadding: CGFloat = 10
            static let topOuterPadding: CGFloat = 5
            static let blurRadiusFocused: CGFloat = 0
            static let blurRadiusUnfocused: CGFloat = 10
            static let backgroundHorizontalPadding: CGFloat = -15
            static let backgroundBottomPadding: CGFloat = -10
            static let backgroundTopPadding: CGFloat = -100
            static let shadowOpacity1: CGFloat = 0.08
            static let shadowOpacity2: CGFloat = 0.05
            static let shadowRadius: CGFloat = 5
            static let shadowOffset: CGFloat = 5
        }
    }

    @FocusState private var isFocused: Bool
    @Binding var searchText: String

    // MARK: - Building blocks
    private var searchIcon: some View {
        Image(systemName: "magnifyingglass")
    }

    private var textFieldView: some View {
        TextField("Search Photos", text: $searchText)
            .focused($isFocused)
    }

    private var clearButton: some View {
        FancyButton(style: .xmark) {
            Task { @MainActor in
                withAnimation(.spring(
                    response: Constants.Animation.response,
                    dampingFraction: Constants.Animation.dampingFraction,
                    blendDuration: Constants.Animation.blendDuration
                )) {
                    searchText = ""
                }
            }
        }
    }

    private var headerContent: some View {
        HStack(spacing: Constants.Layout.iconSpacing) {
            searchIcon
            textFieldView
            clearButton
        }
        .padding(.vertical, Constants.Layout.verticalPadding)
        .padding(.horizontal, Constants.Layout.horizontalPadding)
    }

    private var headerBackground: some View {
        RoundedRectangle(
            cornerRadius: isFocused ? Constants.Layout.cornerRadiusFocused : Constants.Layout.cornerRadiusUnfocused
        )
        .fill(
            .ultraThinMaterial
                .shadow(
                    .drop(
                        color: .black.opacity(Constants.Layout.shadowOpacity1),
                        radius: Constants.Layout.shadowRadius,
                        x: Constants.Layout.shadowOffset,
                        y: Constants.Layout.shadowOffset
                    )
                )
                .shadow(
                    .drop(
                        color: .black.opacity(Constants.Layout.shadowOpacity2),
                        radius: Constants.Layout.shadowRadius,
                        x: -Constants.Layout.shadowOffset,
                        y: -Constants.Layout.shadowOffset
                    )
                )
        )
        .padding(.top, isFocused ? Constants.Layout.topPaddingFocused : Constants.Layout.topPaddingUnfocused)
    }

    private var decoratedHeader: some View {
        headerContent
            .background { headerBackground }
            .padding(
                .horizontal,
                isFocused ? Constants.Layout.horizontalPaddingFocused : Constants.Layout.horizontalPaddingUnfocused
            )
            .padding(.bottom, Constants.Layout.bottomPadding)
            .padding(.top, Constants.Layout.topOuterPadding)
    }

    private var backgroundBlur: some View {
        ProgressiveBlurView()
            .blur(radius: isFocused ? Constants.Layout.blurRadiusFocused : Constants.Layout.blurRadiusUnfocused)
            .padding(.horizontal, Constants.Layout.backgroundHorizontalPadding)
            .padding(.bottom, Constants.Layout.backgroundBottomPadding)
            .padding(.top, Constants.Layout.backgroundTopPadding)
    }

    @ViewBuilder
    private var textField: some View {
        let focused = isFocused

        VStack(spacing: .zero) {
            decoratedHeader
        }
        .background { backgroundBlur }
        .visualEffect { content, proxy in
            content
                .offset(y: offsetY(proxy, isFocused: focused))
        }
    }

    public var body: some View {
        textField
    }

    public init(
        searchText: Binding<String>
    ) {
        _searchText = searchText
    }

    nonisolated private func offsetY(_ proxy: GeometryProxy, isFocused: Bool) -> CGFloat {
        let minY = proxy.frame(in: .scrollView(axis: .vertical)).minY
        return minY > 0 ? (isFocused ? -minY : 0) : -minY
    }
}

#Preview {
    @Previewable @State var searchText = ""

    CustomTextField(searchText: $searchText)
}
