// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "mcp-foundation-models",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "mcp-foundation-models", targets: ["mcp-foundation-models"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.1"),
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.9.0"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "mcp-foundation-models",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle")
            ],
            path: "Sources/"
        )
    ]
)
