// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "telltime",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(name: "TTSCore", targets: ["TTSCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.11.0"),
        .package(url: "https://github.com/renaudjenny/swift-tts", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "TTSCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "SwiftTTSDependency", package: "swift-tts"),
            ]
        ),
        .testTarget(name: "TTSCoreTests", dependencies: ["TTSCore"]),
    ]
)
