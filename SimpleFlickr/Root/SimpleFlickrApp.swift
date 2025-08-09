//
//  SimpleFlickrApp.swift
//  SimpleFlickr
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI
import Utilities

@main
struct AppEntryPoint {

    static func main() {
        if Utilities.isUnitTesting {
            TestingApp.main()
        } else {
            AIChatCourseApp.main()
        }
    }
}

struct AIChatCourseApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            Group {
                if Utilities.isUITesting {
                    AppViewForUITesting(container: delegate.dependencies.container)
                } else {
                    delegate.builder.build()
                }
            }
            .environment(delegate.dependencies.logManager)
        }
    }
}

struct AppViewForUITesting: View {

    var container: DependencyContainer

    private var rootBuilder: RootBuilder {
        RootBuilder(
            interactor: RootInteractor(container: container),
            loggedInRIB: {
                CoreBuilder(interactor: CoreInteractor(container: container))
            }
        )
    }

    private var coreBuilder: CoreBuilder {
        CoreBuilder(interactor: CoreInteractor(container: container))
    }

    private var startOnAvatarScreen: Bool {
        ProcessInfo.processInfo.arguments.contains("STARTSCREEN_CREATEAVATAR")
    }

    var body: some View {
        rootBuilder.build()
//        if startOnAvatarScreen {
//            RouterView { router in
//                coreBuilder.createAvatarView(router: router)
//            }
//        } else {
//            rootBuilder.build()
//        }
    }
}

struct TestingApp: App {
    var body: some Scene {
        WindowGroup {
            Text("Testing!")
        }
    }
}
