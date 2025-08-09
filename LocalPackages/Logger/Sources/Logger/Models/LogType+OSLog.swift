//
//  LogType+OSLog.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//
import OSLog

extension LogType {
    var OSLogType: OSLogType {
        switch self {
        case .info: .info
        case .analytic: .default
        case .warning: .error
        case .severe: .fault
        }
    }
}
