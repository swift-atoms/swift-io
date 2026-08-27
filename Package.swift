// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-io",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "IO",
            targets: ["IO"]
        ),
        .library(
            name: "IO Standard Library Integration",
            targets: ["IO Standard Library Integration"]
        ),
        .library(
            name: "IO Apple Foundation Integration",
            targets: ["IO Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IO",
            dependencies: []
        ),
        .target(
            name: "IO Standard Library Integration",
            dependencies: ["IO"]
        ),
        .target(
            name: "IO Apple Foundation Integration",
            dependencies: [
                "IO",
                "IO Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "IO Tests",
            dependencies: ["IO"],
            path: "Tests/IO Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
