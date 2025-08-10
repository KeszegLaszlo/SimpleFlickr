// swift-tools-version: 6.1
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("StrictConcurrency"),
    .unsafeFlags(["-warn-concurrency", "-enable-actor-data-race-checks"])
]

let package = Package(
    name: "UserInterface",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "UserInterface", targets: ["UserInterface"])
    ],
    dependencies: [
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "UserInterface",
            dependencies: [
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI")
            ],
            swiftSettings: swiftSettings,
            plugins: []
        ),
        .testTarget(
            name: "UserInterfaceTests",
            dependencies: ["UserInterface"]
        )
    ]
)
