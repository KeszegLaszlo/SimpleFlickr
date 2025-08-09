//
//  LogManager.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI

@MainActor
@Observable
public class LogManager {
    private let services: [LogService]

    public init(services: [LogService] = []) {
        self.services = services
    }
    
    public func trackEvent(eventName: String, parameters: [String : Any]? = nil, type: LogType = .analytic) {
        let event = AnyLoggableEvent(eventName: eventName, parameters: parameters, type: type)
        for service in services {
            service.trackEvent(event: event)
        }
    }
    
    public func trackEvent(event: AnyLoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }

    public func trackEvent(event: LoggableEvent) {
        for service in services {
            service.trackEvent(event: event)
        }
    }

    public func trackScreenView(event: LoggableEvent) {
        for service in services {
            service.trackScreenView(event: event)
        }
    }
}
