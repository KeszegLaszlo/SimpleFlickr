//
//  SimpleFlickrUITests.swift
//  SimpleFlickrUITests
//
//  Created by Keszeg László on 2025.08.11.
//

import XCTest

@MainActor
final class SimpleFlickrUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
