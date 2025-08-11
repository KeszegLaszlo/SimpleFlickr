//
//  GlobalRouter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Router
import SwiftUI

@MainActor
protocol GlobalRouter {
    var router: AnyRouter { get }
}

extension GlobalRouter {

    func dismissScreen() {
        router.dismissScreen()
    }

    func dismissModal() {
        router.dismissModal()
    }

    func showInfo(text: LocalizedStringKey) {
        router.showInfo(text: text)
    }

    func showAlert(_ option: AlertType, title: LocalizedStringKey, subtitle: LocalizedStringKey?, buttons: (@Sendable () -> AnyView)?) {
        router.showAlert(option, title: title, subtitle: subtitle, buttons: buttons)
    }

    func showSimpleAlert(title: LocalizedStringKey, subtitle: LocalizedStringKey?) {
        router.showAlert(.alert, title: title, subtitle: subtitle, buttons: nil)
    }

    func showAlert(error: Error) {
        router.showAlert(.alert, title: "Error", subtitle: LocalizedStringKey(error.localizedDescription), buttons: nil)
    }

    func dismissAlert() {
        router.dismissAlert()
    }

    func showLoader(show: Bool) {
        router.showLoader(show: show)
    }
}
