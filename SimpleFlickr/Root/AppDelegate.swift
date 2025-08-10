//
//  AppDelegate.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09..
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
        //TODO: Handle initialization error
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
    
    func configure() {
        switch self {
        case .mock:
            // Mock build does NOT run Firebase
            break //TODO: remove
        case .dev:
            break //TODO: remove
            let plist = Bundle.main.path(forResource: Constants.devGoogleSerrvicePlist, ofType: Constants.plistType)!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            break
            let plist = Bundle.main.path(forResource: Constants.prodGoogleSerrvicePlist, ofType: Constants.plistType)!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}
