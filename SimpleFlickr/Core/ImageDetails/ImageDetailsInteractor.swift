//
//  ImageDetailsInteractor.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

@MainActor
protocol ImageDetailsInteractor {
    func trackScreenEvent(event: LoggableEvent)
    func trackEvent(event: LoggableEvent)
}

extension CoreInteractor: ImageDetailsInteractor { }
