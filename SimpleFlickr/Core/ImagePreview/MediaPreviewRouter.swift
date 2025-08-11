//
//  ImagePreviewRouter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation

@MainActor
protocol MediaPreviewRouter {
    func dismissScreen()
}
extension CoreRouter: MediaPreviewRouter { }
