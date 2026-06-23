// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-tiny-sequence",
    products: [
        .library(
            name: "TinyArray",
            targets: ["TinyArray"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.6.0")
    ],
    targets: [
        .target(
            name: "TinyArray",
            dependencies: [
                "RigidArrayImpl",
                .product(name: "BasicContainers", package: "swift-collections"),
            ],
            swiftSettings: settings
        ),
        .target(
            name: "RigidArrayImpl",
            swiftSettings: settings
        ),
        .testTarget(
            name: "TinyArrayTests",
            dependencies: [
                "TinyArray",
                .product(name: "BasicContainers", package: "swift-collections"),
            ],
            swiftSettings: settings
        ),
    ],
    swiftLanguageModes: [.v6]
)

var settings: [SwiftSetting] {
    [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("StrictMemorySafety"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature(
            "AvailabilityMacro=SwiftStdlib 5.1:macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0"
        ),
        .enableExperimentalFeature(
            "AvailabilityMacro=SwiftStdlib 5.3:macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0"
        ),
        .enableExperimentalFeature(
            "AvailabilityMacro=SwiftStdlib 6.2:macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, visionOS 26.0"
        ),
    ]
}
