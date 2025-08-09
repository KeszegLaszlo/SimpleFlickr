// swift-tools-version: 6.1
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

let package = Package(
    name: "Utilities",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Utilities", targets: ["Utilities"])
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.57.1")
    ],
    targets: [
        .target(
            name: "Utilities",
            swiftSettings: swiftSettings,
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: ["Utilities"]
        )
    ]
)
