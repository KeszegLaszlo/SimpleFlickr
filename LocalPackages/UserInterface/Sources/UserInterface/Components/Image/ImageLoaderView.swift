//
//  ImageLoaderView.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import SDWebImageSwiftUI

public struct ImageLoaderView: View {
    private enum Constants {
        static let opacity = 0.5
    }

    private let urlString: String
    private let resizingMode: ContentMode
    private let forceTransitionAnimation: Bool

    public var body: some View {
        Rectangle()
            .opacity(Constants.opacity)
            .overlay(
                WebImage(url: URL(string: urlString))
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
        urlString: String,
        resizingMode: ContentMode = .fill,
        forceTransitionAnimation: Bool = false
    ) {
        self.urlString = urlString
        self.resizingMode = resizingMode
        self.forceTransitionAnimation = forceTransitionAnimation
    }
}

#Preview {
    ImageLoaderView(urlString: "https://picsum.photos/600/600")
        .frame(width: 100, height: 200)
        .anyButton(.highlight) { }
}
