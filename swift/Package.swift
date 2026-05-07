// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "anvil",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "ClaudeFleetCore", targets: ["ClaudeFleetCore"]),
        .executable(name: "anvil", targets: ["anvil"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "ClaudeFleetCore",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
            ]
        ),
        .executableTarget(
            name: "anvil",
            dependencies: [
                "ClaudeFleetCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "ClaudeFleetCoreTests",
            dependencies: ["ClaudeFleetCore"],
            resources: [.copy("Fixtures")]
        ),
    ]
)
