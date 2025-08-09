//
//  ConsoleService.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation

public struct ConsoleService: LogService {

    private var printParameters: Bool
    private let logger = LogSystem()
    
    public init(printParameters: Bool = true) {
        self.printParameters = printParameters
    }

    public func trackEvent(event: any LoggableEvent) {
        var value = "\(event.type.emoji) \(event.eventName)"
        if printParameters, let params = event.parameters, !params.isEmpty {
            let sortedKeys = params.keys.sorted()
            for key in sortedKeys {
                if let paramValue = params[key] {
                    value += "\n  (key: \"\(key)\", value: \(paramValue))"
                }
            }
        }

        logger.log(level: event.type, message: "\(value)")
    }

    public func trackScreenView(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
