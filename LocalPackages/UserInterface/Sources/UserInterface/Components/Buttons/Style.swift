//
//  Style.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI

public extension FancyButton {
    enum Style {
        case xmark

        public var iconName: String {
            switch self {
            case .xmark: "xmark.circle.fill"
            }
        }
        public var foregroundColor: Color {
            switch self {
            case .xmark: .white
            }
        }
        public var backgroundColor: Color {
            switch self {
            case .xmark: .secondary
            }
        }
    }
}

public struct FancyButton: View {
    public let style: Style
    public var onTap: @Sendable @MainActor () -> Void
    public var size: CGFloat

    private enum Constants {
        static let animationResponse: CGFloat = 0.35
        static let animationDamping: CGFloat = 0.6
        static let animationBlend: CGFloat = 0.5
        static let animatedScale: CGFloat = 1.2
        static let normalScale: CGFloat = 1.0
        static let rotationDegrees: Double = 180
        static let normalShadowRadius: CGFloat = 3
        static let animatedShadowRadius: CGFloat = 7
        static let shadowOpacity: Double = 0.25
        static let backgroundWidthFactor: CGFloat = 1.15
        static let backgroundHeightFactor: CGFloat = 1.2
        static let animationDelay: Double = 0.35
    }

    @State private var isAnimating = false

    private var springAnimation: Animation {
        .spring(
            response: Constants.animationResponse,
            dampingFraction: Constants.animationDamping,
            blendDuration: Constants.animationBlend
        )
    }

     public init(
        style: Style = .xmark,
        size: CGFloat = 22,
        onTap: @escaping @Sendable @MainActor () -> Void
    ) {
        self.style = style
        self.size = size
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            withAnimation(springAnimation) {
                isAnimating = true
                onTap()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDelay) {
                isAnimating = false
            }
        } label: {
            Image(systemName: style.iconName)
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(style.foregroundColor)
                .background(
                    Circle()
                        .fill(style.backgroundColor)
                        .frame(
                            width: size * Constants.backgroundWidthFactor,
                            height: size * Constants.backgroundHeightFactor
                        )
                )
                .scaleEffect(isAnimating ? Constants.animatedScale : Constants.normalScale)
                .rotationEffect(.degrees(isAnimating ? Constants.rotationDegrees : 0))
                .shadow(
                    color: style.backgroundColor.opacity(Constants.shadowOpacity),
                    radius: isAnimating ? Constants.animatedShadowRadius : Constants.normalShadowRadius
                )
                .animation(springAnimation, value: isAnimating)
                .accessibilityLabel("Fancy button")
        }
        .buttonStyle(.plain)
    }
}
