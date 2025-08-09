// swift-tools-version: 6.1
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("ForwardTrailingClosures"),
    .enableUpcomingFeature("ImplicitOpenExistentials"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

let package = Package(
    name: "Logger",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Logger", targets: ["Logger"]),
        .library(name: "LoggerFirebaseAnalytics", targets: ["LoggerFirebaseAnalytics"]),
        .library(name: "LoggerFirebaseCrashlytics", targets: ["LoggerFirebaseCrashlytics"])
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.57.1"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.0.0")
    ],
    targets: [
        // Core logging protocols / shared types
        .target(name: "Logger"),

        // Firebase Analytics logger
        .target(
            name: "LoggerFirebaseAnalytics",
            dependencies: [
                "Logger",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ]
        ),

        // Firebase Crashlytics logger
        .target(
            name: "LoggerFirebaseCrashlytics",
            dependencies: [
                "Logger",
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ],
            swiftSettings: swiftSettings,
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),

        .testTarget(
            name: "LoggerTests",
            dependencies: ["Logger"]
        )
    ]
)
