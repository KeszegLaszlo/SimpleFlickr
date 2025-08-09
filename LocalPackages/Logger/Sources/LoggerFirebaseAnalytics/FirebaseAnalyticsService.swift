//
//  FirebaseAnalyticsService.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation
import FirebaseAnalytics
import Logger

public struct FirebaseAnalyticsService: LogService {
    
    public static var appInstanceID: String? {
        Analytics.appInstanceID()
    }

    public init() {
        
    }

    public func trackEvent(event: LoggableEvent) {
        // Firebase allows up to 500 unique events
        // https://firebase.google.com/docs/analytics/events?platform=ios

        var parameters = event.parameters ?? [:]
        
        // Firebase Analytics supports several value types, but not all.
        // I can't find documentation, but if a bad value is sent, it will log to console.
        // Unsupported Types:
        //  - Date
        //  - Arrays
        //
        for (key, value) in parameters {
            // Convert Date to String
            if let date = value as? Date, let string = convertToString(date) {
                parameters[key] = string
                
            // Firebase Analytics doesn't allow Arrays
            } else if let array = value as? [Any] {
                if let string = convertToString(array) {
                    parameters[key] = string
                } else {
                    parameters[key] = nil
                }
            }
        }
        
        for (key, value) in parameters {
            // Keys are limited to 40 characters
            if key.count > 40 {
                parameters.removeValue(forKey: key)
                
                let newKey = key.clean(maxCharacters: 40)
                parameters[newKey] = value
            }
        }
        
        for (key, value) in parameters {
            // Values are limited to 100 characters
            if let string = value as? String {
                parameters[key] = string.clean(maxCharacters: 100)
            }
        }
        
        // Parameters are limited to 25
        parameters.first(upTo: 25)

        // Event names are limited to 40 characters
        let name = event.eventName.clean(maxCharacters: 40)
        let params = parameters.isEmpty ? nil : parameters
        Analytics.logEvent(name, parameters: params)
    }

    public func trackScreenView(event: any LoggableEvent) {
        // Firebase has a special event for tracking screen views
        let screenName = event.eventName.clean(maxCharacters: 40)
        
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName
        ])
    }
    
    private func convertToString(_ value: Any) -> String? {
        switch value {
        case let value as String:
            return value
        case let value as Int:
            return String(value)
        case let value as Double:
            return String(value)
        case let value as Float:
            return String(value)
        case let value as Bool:
            return String(value)
        case let value as Date:
            return value.formatted(date: .abbreviated, time: .shortened)
        case let array as [Any]:
            return array.compactMap { convertToString($0) }.sorted().joined(separator: ", ")
        case let value as CustomStringConvertible:
            return value.description
        default:
            return nil
        }
    }
}
