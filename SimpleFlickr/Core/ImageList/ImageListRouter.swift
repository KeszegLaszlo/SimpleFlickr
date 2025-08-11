//
//  ImageListRouter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

@MainActor
protocol ImageListRouter {
    func showImageDetails(delegate: DetailsViewDelegate)
    func showAlert(error: Error)
}
extension CoreRouter: ImageListRouter { }
