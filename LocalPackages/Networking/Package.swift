// swift-tools-version: 6.1
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

let package = Package(
    name: "CustomNetworking",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CustomNetworking", targets: ["CustomNetworking"])
    ],
    dependencies: [
        .package(name: "Logger", path: "../Logger")
    ],
    targets: [
        .target(
            name: "CustomNetworking",
            dependencies: [
                .product(name: "Logger", package: "Logger")
            ],
            swiftSettings: swiftSettings,
            plugins: []
        ),
        .testTarget(
            name: "CustomNetworkingTests",
            dependencies: ["CustomNetworking"]
        )
    ]
)
