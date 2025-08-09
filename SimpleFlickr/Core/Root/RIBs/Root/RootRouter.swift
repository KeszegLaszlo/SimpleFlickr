//
//  RootRouter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

@MainActor
struct RootRouter: GlobalRouter {
    let router: AnyRouter
    let builder: RootBuilder
}
