// swift-tools-version: 6.1
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

let package = Package(
    name: "Router",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "Router", targets: ["Router"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Router",
            swiftSettings: swiftSettings,
            plugins: []
        ),
        .testTarget(
            name: "RouterTests",
            dependencies: ["Router"]
        )
    ]
)
