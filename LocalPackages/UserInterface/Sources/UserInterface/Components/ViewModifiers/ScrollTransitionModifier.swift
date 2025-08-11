//
//  ScrollTransitionModifier.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI

struct ScrollTransitionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.3)
                    .scaleEffect(phase.isIdentity ? 1 : 0.75)
                    .blur(radius: phase.isIdentity ? 0 : 5)
            }
    }
}
