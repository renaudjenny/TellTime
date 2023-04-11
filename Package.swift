// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "telltime",
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(name: "ConfigurationFeature", targets: ["ConfigurationFeature"]),
        .library(name: "SpeechRecognizerCore", targets: ["SpeechRecognizerCore"]),
        .library(name: "TTSCore", targets: ["TTSCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/renaudjenny/SwiftClockUI", from: "2.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.52.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.11.0"),
        .package(url: "https://github.com/renaudjenny/swift-speech-recognizer", branch: "main"),
        .package(url: "https://github.com/renaudjenny/swift-tts", from: "2.1.2"),
    ],
    targets: [
        .target(
            name: "ConfigurationFeature",
            dependencies: [
                .product(name: "SwiftClockUI", package: "SwiftClockUI"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "ConfigurationFeatureTests",
            dependencies: [
                "ConfigurationFeature",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .target(
            name: "SpeechRecognizerCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftSpeechRecognizerDependency", package: "swift-speech-recognizer"),
            ]
        ),
        .testTarget(name: "SpeechRecognizerCoreTests", dependencies: ["SpeechRecognizerCore"]),
        .target(
            name: "TTSCore",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SwiftTTSDependency", package: "swift-tts"),
            ]
        ),
        .testTarget(
            name: "TTSCoreTests",
            dependencies: [
                "TTSCore",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ]
)
