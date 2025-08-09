//
//  LogType.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//
import Foundation

public enum LogType: Int, CaseIterable, Sendable {
    /// Use 'info' for informative tasks, such as tracking functions. These logs should not be considered issues or errors.
    case info // 0
    /// Use 'analytic'' for all analytic events.
    case analytic // 1
    /// Use 'warning' for issues or errors that should not occur, but will not negatively affect user experience.
    case warning // 2
    /// Use 'severe' for issues or errors that will negatively affect user experience, such as crashes or failing scenarios. Production builds should not have any 'severe' occurrences.
    case severe // 3

    var emoji: String {
        switch self {
        case .info: "👋"
        case .analytic: "📈"
        case .warning: "⚠️"
        case .severe: "🚨"
        }
    }

    var asString: String {
        switch self {
        case .info: "info"
        case .analytic: "analytic"
        case .warning: "warning"
        case .severe: "severe"
        }
    }
}
