//
//  LoggableEvent.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

public protocol LoggableEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: LogType { get }
}
