//
//  ImageLoaderView.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI
import SDWebImageSwiftUI
import Utilities

public struct ImageLoaderView: View {
    private enum Constants {
        static let opacity = 0.5
    }

    private let url: URL
    private let resizingMode: ContentMode
    private let forceTransitionAnimation: Bool

    public var body: some View {
        Rectangle()
            .opacity(Constants.opacity)
            .overlay(
                WebImage(url: url)
                    .resizable()
                    .indicator(.activity)
                    .aspectRatio(contentMode: resizingMode)
                    .allowsHitTesting(false)
            )
            .clipped()
            .ifSatisfiedCondition(forceTransitionAnimation) { content in
                content
                    .drawingGroup()
            }
    }

    public init(
        url: URL,
        resizingMode: ContentMode = .fill,
        forceTransitionAnimation: Bool = false
    ) {
        self.url = url
        self.resizingMode = resizingMode
        self.forceTransitionAnimation = forceTransitionAnimation
    }
}

#Preview {
    ImageLoaderView(url: Utilities.sampleImageURL)
        .frame(width: 100, height: 200)
        .anyButton(.highlight) { }
}
