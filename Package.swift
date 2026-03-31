// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "XebokiSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "XebokiSDK",
            targets: ["XebokiSDK"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "XebokiSDK",
            dependencies: [],
            path: "Sources/XebokiSDK"
        ),
        .testTarget(
            name: "XebokiSDKTests",
            dependencies: ["XebokiSDK"],
            path: "Tests/XebokiSDKTests"
        ),
    ]
)
