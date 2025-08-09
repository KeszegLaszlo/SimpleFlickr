//
//  ImageDetailsRouter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
//

@MainActor
protocol ImageDetailsRouter {
    func showImagePreview(delegate: MediaDelegate)
}
extension CoreRouter: ImageDetailsRouter {}
