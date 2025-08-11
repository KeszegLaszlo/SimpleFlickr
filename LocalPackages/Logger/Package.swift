// swift-tools-version: 6.0
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

let package = Package(
    name: "Logger",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Logger", targets: ["Logger"]),
        .library(name: "LoggerFirebaseAnalytics", targets: ["LoggerFirebaseAnalytics"]),
        .library(name: "LoggerFirebaseCrashlytics", targets: ["LoggerFirebaseCrashlytics"])
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "11.15.0")
    ],
    targets: [
        .target(
            name: "Logger",
            swiftSettings: swiftSettings,
            plugins: []
        ),

        .target(
            name: "LoggerFirebaseAnalytics",
            dependencies: [
                "Logger",
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk")
            ],
            swiftSettings: swiftSettings,
            plugins: []
        ),

        .target(
            name: "LoggerFirebaseCrashlytics",
            dependencies: [
                "Logger",
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ],
            swiftSettings: swiftSettings,
            plugins: []
        ),

        .testTarget(
            name: "LoggerTests",
            dependencies: ["Logger", "LoggerFirebaseAnalytics", "LoggerFirebaseCrashlytics"]
        )
    ]
)
