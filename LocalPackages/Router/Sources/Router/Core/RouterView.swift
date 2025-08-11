//
//  RouterView.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI

public struct RouterView<Content: View>: View, RouterProtocol {

    @Environment(\.dismiss) private var dismiss

    @State private var path: [AnyDestination] = []

    @State private var showSheet: AnyDestination?
    @State private var showFullScreenCover: AnyDestination?

    @State private var alert: AnyAppAlert?
    @State private var alertOption: AlertType = .alert

    @State private var showLoader = false
    @State private var infoText: LocalizedStringKey?
    @State private var modalBackgroundColor: Color = Color.black.opacity(0.6)
    @State private var modalTransition: AnyTransition = AnyTransition.opacity
    @State private var modal: AnyDestination?

    // Binding to the view stack from previous RouterViews
    @Binding var screenStack: [AnyDestination]

    var addNavigationView: Bool
    @ViewBuilder var content: (any RouterProtocol) -> Content

    public init(
        screenStack: (Binding<[AnyDestination]>)? = nil,
        addNavigationView: Bool = true,
        content: @escaping (any RouterProtocol) -> Content
    ) {
        self._screenStack = screenStack ?? .constant([])
        self.addNavigationView = addNavigationView
        self.content = content
    }

    public var body: some View {
        NavigationStackIfNeeded(path: $path, addNavigationView: addNavigationView) {
            content(self)
                .sheetViewModifier(screen: $showSheet)
                .fullScreenCoverViewModifier(screen: $showFullScreenCover)
                .showCustomAlert(type: alertOption, alert: $alert)
                .loading($showLoader)
                .infoOverlay($infoText)
        }
        .modalViewModifier(backgroundColor: modalBackgroundColor, transition: modalTransition, screen: $modal)
        .environment(\.router, self)
    }

    public func showScreen<T: View>(
        _ option: SegueOption,
        @ViewBuilder destination: @escaping (any RouterProtocol) -> T
    ) {
        let screen = RouterView<T>(
            screenStack: option.shouldAddNewNavigationView ? nil : (screenStack.isEmpty ? $path : $screenStack),
            addNavigationView: option.shouldAddNewNavigationView
        ) { newRouter in
            destination(newRouter)
        }

        let destination = AnyDestination(destination: screen)

        switch option {
        case .push:
            if screenStack.isEmpty {
                // This means we are in the first RouterView
                path.append(destination)
            } else {
                // This means we are in a secondary RouterView
                screenStack.append(destination)
            }
        case .sheet:
            showSheet = destination
        case .fullScreenCover:
            showFullScreenCover = destination
        }
    }

    public func dismissScreen() {
        dismiss()
    }

    public func showAlert(
        _ option: AlertType,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey? = nil,
        buttons: (@Sendable () -> AnyView)? = nil
    ) {
        if showLoader {
            showLoader = false
        }
        self.alertOption = option
        self.alert = AnyAppAlert(title: title, subtitle: subtitle, buttons: buttons)
    }

    public func dismissAlert() {
        alert = nil
    }

    public func showLoader(show: Bool) {
        showLoader = show
    }

    public func showInfo(text: LocalizedStringKey) {
        withAnimation {
            infoText = text
        }
    }

    public func showModal<T: View>(
        backgroundColor: Color,
        transition: AnyTransition,
        @ViewBuilder destination: @escaping () -> T
    ) {
        self.modalBackgroundColor = backgroundColor
        self.modalTransition = transition
        let destination = AnyDestination(destination: destination())
        self.modal = destination
    }

    public func dismissModal() {
        modal = nil
    }
}
