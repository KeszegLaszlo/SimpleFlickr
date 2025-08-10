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
    dependencies: [],
    targets: [
        .target(
            name: "Utilities",
            swiftSettings: swiftSettings,
            plugins: []
        ),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: ["Utilities"]
        )
    ]
)
