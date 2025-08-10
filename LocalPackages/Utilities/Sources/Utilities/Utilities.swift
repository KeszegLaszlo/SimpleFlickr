//
//  FirebaseCrashlyticsService.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

import UIKit

@MainActor
public struct Utilities {
    public static var isUnitTesting: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    public static var isUITesting: Bool {
        ProcessInfo.processInfo.arguments.contains("UI_TESTING")
    }

    /// A Boolean value indicating whether the device is in portrait orientation.
    public static var isPortrait: Bool {
        UIDevice.current.orientation.isPortrait
    }

    /// A Boolean value indicating whether the device is in landscape orientation.
    public static var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }

    public static let sampleImageURL = URL(string: "https://picsum.photos/600/600")!

}

public extension Bundle {
    func apiKey(for infoDictionaryKey: String) -> String? {
        guard let data = object(forInfoDictionaryKey: infoDictionaryKey) as? Data else {
            return nil
        }
        // Convert bytes back to lowercase hex string
        return data.map { String(format: "%02x", $0) }.joined()
    }
}
