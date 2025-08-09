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
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.57.1")
    ],
    targets: [
        .target(
            name: "Router",
            swiftSettings: swiftSettings,
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
        ),
        .testTarget(
            name: "RouterTests",
            dependencies: ["Router"]
        )
    ]
)
