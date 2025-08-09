//
//  View+Extensions.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

extension View {
    func loading(_ isLoading: Binding<Bool>) -> some View {
        self.modifier(LoadingModifier(isLoading: isLoading))
    }

    func infoOverlay(_ text: Binding<LocalizedStringKey?>) -> some View {
        self.modifier(InfoOverlayModifier(text: text))
    }
}

// MARK: - Custom Loading View Modifier
struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 10 : 0)

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3).ignoresSafeArea())
                    .tint(.indigo)
            }
        }
    }
}

// MARK: - Info Overlay View Modifier
struct InfoOverlayModifier: ViewModifier {
    @Binding var text: LocalizedStringKey?

    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: text == nil ? .zero : 10)
            if let message = text {
                VStack(spacing: 20) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(.indigo)
                        .shadow(radius: 4)

                    Text(message)
                        .multilineTextAlignment(.center)
                        .font(.title3.weight(.medium))
                        .padding()
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(radius: 1)

                    Button {
                        withAnimation {
                            text = nil
                        }
                    } label: {
                        Text("Got it 🫣")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
                .padding()
                .frame(maxWidth: 300)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .shadow(radius: 8)
                )
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity.combined(with: .scale))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: text)
            }
        }
        .transition(.slide)
    }
}
