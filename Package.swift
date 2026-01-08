// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-tiny-sequence",
    products: [
        .library(
            name: "TinySequence",
            targets: ["TinySequence"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "TinySequenceCore",
            swiftSettings: settings
        ),
        .target(
            name: "TinySequence",
            dependencies: [
                "TinySequenceImpl",
                "RigidArrayPlusTinySequence",
                "UniqueArrayPlusTinySequence",
            ],
            swiftSettings: settings
        ),
        .target(
            name: "TinySequenceImpl",
            swiftSettings: settings
        ),
        .target(
            name: "RigidArrayPlusTinySequence",
            dependencies: [
                "TinySequenceCore",
                "TinySequenceImpl",
                .product(name: "BasicContainers", package: "swift-collections"),
            ],
            swiftSettings: settings
        ),
        .target(
            name: "UniqueArrayPlusTinySequence",
            dependencies: [
                "TinySequenceCore",
                "TinySequenceImpl",
                .product(name: "BasicContainers", package: "swift-collections"),
            ],
            swiftSettings: settings
        ),
        .testTarget(
            name: "TinySequenceTests",
            dependencies: [
                "TinySequence",
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature(
            "AvailabilityMacro=swiftTinySequenceApplePlatforms 26:macOS 26, iOS 26, tvOS 26, watchOS 26, visionOS 26"
        ),
        .enableExperimentalFeature(
            "AvailabilityMacro=swiftTinySequenceApplePlatforms 11:macOS 11, iOS 14, tvOS 14, watchOS 7"
        ),
        .enableExperimentalFeature(
            "AvailabilityMacro=swiftTinySequenceApplePlatforms 10.15:macOS 10.15, iOS 13, tvOS 13, watchOS 6"
        ),
    ]
}
