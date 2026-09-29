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

        .library(name: "IO Foundation Integration", targets: ["IO Foundation Integration"]),
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
            name: "IO Foundation Integration",
            dependencies: [
                .target(name: "IO"),
            ],
            path: "Sources/IO Foundation Integration"
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
                .target(name: "IO Foundation Integration"),
            ],
            path: "Tests/IO Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
