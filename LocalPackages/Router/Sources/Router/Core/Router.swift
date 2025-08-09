//
//  NavigationStackIfNeeded.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI

extension EnvironmentValues {
    @Entry var router: any Router = MockRouter()
}

@MainActor
protocol Router {
    func showScreen<T: View>(_ option: SegueOption, @ViewBuilder destination: @escaping (any Router) -> T)
    func dismissScreen()

    func showAlert(
        _ option: AlertType,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey?,
        buttons: (@Sendable () -> AnyView)?
    )
    func dismissAlert()

    func showModal<T: View>(
        backgroundColor: Color,
        transition: AnyTransition,
        @ViewBuilder destination: @escaping () -> T
    )
    func dismissModal()

    func showLoader(show: Bool)
    func showInfo(text: LocalizedStringKey)
}

struct MockRouter: Router {
    func showInfo(text: LocalizedStringKey) {
        print("Mock router does not work.")
    }

    func showScreen<T: View>(
        _ option: SegueOption,
        @ViewBuilder destination: @escaping (any Router) -> T
    ) where T: View {
        print("Mock router does not work.")
    }
    func dismissScreen() {
        print("Mock router does not work.")
    }
    func showAlert(
        _ option: AlertType,
        title: LocalizedStringKey,
        subtitle: LocalizedStringKey?,
        buttons: (() -> AnyView)?
    ) {
        print("Mock router does not work.")
    }
    func dismissAlert() {
        print("Mock router does not work.")
    }
    func showModal<T: View>(
        backgroundColor: Color,
        transition: AnyTransition,
        @ViewBuilder destination: @escaping () -> T
    ) where T: View {
        print("Mock router does not work.")
    }
    func dismissModal() {
        print("Mock router does not work.")
    }

    func showLoader(show: Bool) {
        print("Mock router does not work.")
    }
}
