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
        .library(name: "IO", targets: ["IO"]),
        .library(name: "IO Standard Library Integration", targets: ["IO Standard Library Integration"]),
        .library(name: "IO Foundation Library Integration", targets: ["IO Foundation Library Integration"]),
        .library(name: "IO Test Support", targets: ["IO Test Support"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "IO",
            dependencies: [
            ],
            path: "Sources/IO"
        ),
        .target(
            name: "IO Standard Library Integration",
            dependencies: [
                .target(name: "IO"),
            ],
            path: "Sources/IO Standard Library Integration"
        ),
        .target(
            name: "IO Foundation Library Integration",
            dependencies: [
                .target(name: "IO"),
                .target(name: "IO Standard Library Integration"),
            ],
            path: "Sources/IO Foundation Library Integration"
        ),
        .target(
            name: "IO Test Support",
            dependencies: [
                .target(name: "IO"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "IO Tests",
            dependencies: [
                .target(name: "IO"),
                .target(name: "IO Test Support"),
                .target(name: "IO Standard Library Integration"),
                .target(name: "IO Foundation Library Integration"),
            ],
            path: "Tests/IO Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
