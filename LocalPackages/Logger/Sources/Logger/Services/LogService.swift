//
//  LogService.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

public protocol LogService: Sendable {
    func trackEvent(event: any LoggableEvent)
    func trackScreenView(event: any LoggableEvent)
}
