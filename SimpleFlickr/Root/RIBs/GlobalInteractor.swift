//
//  GlobalInteractor.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

@MainActor
protocol GlobalInteractor {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func trackEvent(event: AnyLoggableEvent)
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
}
