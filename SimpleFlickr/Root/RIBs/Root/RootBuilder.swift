//
//  RootBuilder.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

import SwiftUI
import UserInterface

@MainActor
struct RootBuilder: Builder {
    let interactor: RootInteractor
    let loggedInRIB: () -> any Builder

    func build() -> AnyView {
        appView().any()
    }
    
    func appView() -> some View {
        loggedInRIB().build()

//        AppView(
//            presenter: AppPresenter(
//                interactor: interactor
//            ),
//            tabbarView: {
//                loggedInRIB().build()
//            },
//            onboardingView: {
//                loggedOutRIB().build()
//            }
//        )
    }
}
