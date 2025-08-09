//
//  MockLoggableEvent.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//
public struct AnyLoggableEvent: LoggableEvent {
    public var eventName: String
    public var type: LogType
    public var parameters: [String: Any]?

    public init(eventName: String, parameters: [String : Any]? = nil, type: LogType = .analytic) {
        self.eventName = eventName
        self.parameters = parameters
        self.type = type
    }
}

