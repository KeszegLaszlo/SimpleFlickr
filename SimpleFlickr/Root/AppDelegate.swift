//
//  AppDelegate.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Firebase
import Utilities
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    var dependencies: Dependencies!
    var builder: RootBuilder!

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        var config: BuildConfiguration

        #if MOCK
        config = .mock
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif

        if Utilities.isUnitTesting {
            config = .mock
        }

        config.configure()
        // TODO: [09/25/2025] Handle initialization error
        dependencies = try? Dependencies(config: config)
        builder = RootBuilder(
            interactor: RootInteractor(container: dependencies.container),
            loggedInRIB: {
                CoreBuilder(interactor: CoreInteractor(container: self.dependencies.container))
            }
        )
        return true
    }
}

enum BuildConfiguration {
    case mock, dev, prod

    /// Configures third-party services for the current build configuration.
    ///
    /// In a typical setup, this method would:
    /// - Locate the appropriate `GoogleService-Info.plist` file for the given configuration (`mock`, `dev`, or `prod`).
    /// - Initialize and configure Firebase with those options.
    ///
    /// The `mock` configuration typically skips Firebase initialization.
    /// The `dev` and `prod` configurations would each point to their respective Firebase project files.
    ///
    /// Currently, Firebase is not set up, so this method is a placeholder.
    func configure() {
        switch self {
        case .mock:
            // Mock build does NOT run Firebase
            break
        case .dev:
            break
            // In the future:
            // let plist = Bundle.main.path(forResource: Constants.devGoogleSerrvicePlist, ofType: Constants.plistType)!
            // let options = FirebaseOptions(contentsOfFile: plist)!
            // FirebaseApp.configure(options: options)
        case .prod:
            break
            // In the future:
            // let plist = Bundle.main.path(forResource: Constants.prodGoogleSerrvicePlist, ofType: Constants.plistType)!
            // let options = FirebaseOptions(contentsOfFile: plist)!
            // FirebaseApp.configure(options: options)
        }
    }
}
