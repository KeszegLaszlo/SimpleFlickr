//
//  RouterView.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

struct RouterView<Content: View>: View, Router {

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
    @ViewBuilder var content: (any Router) -> Content

    init(
        screenStack: (Binding<[AnyDestination]>)? = nil,
        addNavigationView: Bool = true,
        content: @escaping (any Router) -> Content
    ) {
        self._screenStack = screenStack ?? .constant([])
        self.addNavigationView = addNavigationView
        self.content = content
    }

    var body: some View {
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

    func showScreen<T: View>(_ option: SegueOption, @ViewBuilder destination: @escaping (any Router) -> T) {
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

    func dismissScreen() {
        dismiss()
    }

    func showAlert(
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

    func dismissAlert() {
        alert = nil
    }

    func showLoader(show: Bool) {
        showLoader = show
    }

    func showInfo(text: LocalizedStringKey) {
        withAnimation {
            infoText = text
        }
    }

    func showModal<T: View>(
        backgroundColor: Color,
        transition: AnyTransition,
        @ViewBuilder destination: @escaping () -> T
    ) {
        self.modalBackgroundColor = backgroundColor
        self.modalTransition = transition
        let destination = AnyDestination(destination: destination())
        self.modal = destination
    }

    func dismissModal() {
        modal = nil
    }
}
