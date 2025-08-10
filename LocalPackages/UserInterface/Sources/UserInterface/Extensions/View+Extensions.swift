//
//  File.swift
//  UserInterace
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

extension View {
    public var withCustomScrollTransition: some View {
        self.modifier(ScrollTransitionModifier())
    }

    public var withMeshGradientBackground: some View {
        self.modifier(MeshGradientBackground())
    }

    public func any() -> AnyView {
        AnyView(self)
    }

    @ViewBuilder
    public func ifSatisfiedCondition(
        _ condition: Bool,
        transform: (Self) -> some View
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    public func tappableBackground() -> some View {
        background(Color.black.opacity(0.001))
    }

    public func onFirstAppear(action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppearViewModifier(action: action))
    }

    public func onFirstTask(action: @escaping () async -> Void) -> some View {
        modifier(OnFirstTaskViewModifier(action: action))
    }

    func callToActionButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.orange)
            .cornerRadius(16)
    }
}
