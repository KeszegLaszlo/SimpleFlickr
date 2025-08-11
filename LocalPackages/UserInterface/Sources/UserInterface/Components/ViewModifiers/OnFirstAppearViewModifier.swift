//
//  OnFirstAppearViewModifier.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 10.
//

import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    @State private var didAppear: Bool = false
    private let action: @Sendable () -> Void

    public func body(content: Content) -> some View {
        content
            .onAppear {
                guard !didAppear else { return }
                didAppear = true
                action()
            }
    }

    public init(action: @Sendable @escaping () -> Void) {
        self.action = action
    }
}

struct OnFirstTaskViewModifier: ViewModifier {
    @State private var didAppear: Bool = false
    private let action: @Sendable () async -> Void

    public func body(content: Content) -> some View {
        content
            .task {
                guard !didAppear else { return }
                didAppear = true
                await action()
            }
    }

    public init(action: @Sendable @escaping () async -> Void) {
        self.action = action
    }
}
