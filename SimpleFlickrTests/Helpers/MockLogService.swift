//
//  ImagePreviewPresenter.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 11.
//

import SwiftUI
@testable import SimpleFlickr_Dev

final class MockLogService: LogService, @unchecked Sendable {
    
    var trackedEvents: [AnyLoggableEvent] = []
    
    func trackEvent(event: LoggableEvent) {
        let anyEvent = AnyLoggableEvent(eventName: event.eventName, parameters: event.parameters, type: event.type)
        trackedEvents.append(anyEvent)
    }
    
    func trackScreenView(event: LoggableEvent) {
        let anyEvent = AnyLoggableEvent(eventName: event.eventName, parameters: event.parameters, type: event.type)
        trackedEvents.append(anyEvent)
    }
}
