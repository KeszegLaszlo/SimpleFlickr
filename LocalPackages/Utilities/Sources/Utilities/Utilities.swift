//
//  FirebaseCrashlyticsService.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

import UIKit

public struct Utilities {
    public static var isUnitTesting: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    public static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }
}
