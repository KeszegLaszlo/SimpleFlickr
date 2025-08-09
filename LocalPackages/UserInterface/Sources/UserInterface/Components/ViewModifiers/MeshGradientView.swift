//
//  MeshGradientView.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

struct MeshGradientView: View {
    @State var isAnimating = false

    var body: some View {
        ZStack {
            MeshGradient(width: 3, height: 3, points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [isAnimating ? 0.1 : 0.8, 0.5], [1.0, isAnimating ? 0.5 : 1],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ], colors: [
                Color.orange, Color.red, Color.pink,
                Color.orange.opacity(0.4), Color.pink.opacity(0.7), Color.pink.opacity(0.5),
                Color.red.opacity(0.7), Color.orange.opacity(0.5), Color.orange.opacity(0.4)
            ])
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating.toggle()
            }
        }
    }
}

struct MeshGradientBackground: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            MeshGradientView()
            content
        }
    }
}

#Preview {
    MeshGradientView(isAnimating: true)
}
