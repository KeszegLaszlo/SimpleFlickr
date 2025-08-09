//
//  FirebaseCrashlyticsService.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation
import FirebaseCrashlytics
import FirebaseCrashlyticsSwift
import Logger

public struct FirebaseCrashlyticsService: LogService {
    
    public init() {}

    public func trackEvent(event: any LoggableEvent) {
        // Note: Firebase Analytics automatically log breadcrumbs to Crashlytics
        // Therefore, no need to send typical events herein
        // https://firebase.google.com/docs/crashlytics/customize-crash-reports?hl=en&authuser=1&_gl=1*ntknz4*_ga*MTg3MDE4MjY5OC4xNzE3ODAzNTUw*_ga_CW55HF8NVT*MTcyOTg2MDMwNS42My4xLjE3Mjk4NjA2MTcuMjQuMC4w&platform=ios#get-breadcrumb-logs
        
        switch event.type {
        case .info, .analytic, .warning:
            break
        case .severe:
            let error = NSError(
                domain: event.eventName,
                code: event.eventName.stableHashValue,
                userInfo: event.parameters
            )
            Crashlytics.crashlytics().record(error: error, userInfo: event.parameters)
        }
    }

    public func trackScreenView(event: any LoggableEvent) {
        trackEvent(event: event)
    }
}
